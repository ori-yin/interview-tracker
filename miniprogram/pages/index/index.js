// 首页 - 求职记录列表
const { db, applicationsCol, roundsCol, deleteApplication } = require('../../utils/db');
const { formatDateYMD, formatDateMD } = require('../../utils/date');
const { formatApplication, getProcessSteps, getDynamicStatus, getDynamicTheme } = require('../../utils/constants');

const PAGE_SIZE = 20;

Page({
  data: {
    applications: [],
    loading: true,
    isSelectMode: false,
    selectedIds: [],
    isAllSelected: false,
    hasMore: true,
    loadingMore: false,
    searchKeyword: '',
    activeTab: 'all',
    startDate: '',
    endDate: '',
    showDatePicker: false,
    datePresets: [
      { label: '近30天', value: '30', active: true },
      { label: '近90天', value: '90', active: false },
      { label: '全部', value: 'all', active: false },
    ],
  },

  onLoad() {
    this.setPreset('30');
    this.loadApplications(true);
  },

  onShow() {
    if (this._needRefresh) {
      this.loadApplications(true);
      this._needRefresh = false;
    }
  },

  onReachBottom() {
    if (this.data.hasMore && !this.data.loadingMore) {
      this.loadApplications(false);
    }
  },

  // 搜索
  onSearchInput(e) {
    this.setData({ searchKeyword: e.detail.value });
  },

  onSearchConfirm() {
    this.loadApplications(true);
  },

  clearSearch() {
    this.setData({ searchKeyword: '' });
    this.loadApplications(true);
  },

  // 状态筛选
  onTabChange(e) {
    this.setData({ activeTab: e.detail.value });
    this.loadApplications(true);
  },

  // 日期筛选
  toggleDatePicker() {
    this.setData({ showDatePicker: true });
  },

  onDatePickerClose(e) {
    if (!e.detail.visible) {
      this.setData({ showDatePicker: false });
    }
  },

  onDatePresetTap(e) {
    this.setPreset(e.currentTarget.dataset.value);
  },

  setPreset(value) {
    const now = new Date();
    const endDate = formatDateYMD(now);
    let startDate = '';

    if (value === '30') {
      startDate = formatDateYMD(new Date(now.getTime() - 30 * 24 * 3600 * 1000));
    } else if (value === '90') {
      startDate = formatDateYMD(new Date(now.getTime() - 90 * 24 * 3600 * 1000));
    } else {
      startDate = '2020-01-01';
    }

    const datePresets = this.data.datePresets.map(p => ({
      ...p,
      active: p.value === value,
    }));

    this.setData({ startDate, endDate, datePresets });
  },

  onDatePickerCancel() {
    this.setData({ showDatePicker: false });
  },

  onDatePickerConfirm() {
    this.setData({ showDatePicker: false });
    this.loadApplications(true);
  },

  // 构建查询条件
  _buildCondition() {
    const { startDate, endDate, searchKeyword } = this.data;
    const keyword = searchKeyword.trim();

    const conditions = [
      { appliedDate: db.command.gte(startDate).and(db.command.lte(endDate)) },
    ];

    if (keyword) {
      conditions.push(
        db.command.or([
          { companyName: db.RegExp({ regexp: keyword, options: 'i' }) },
          { positionName: db.RegExp({ regexp: keyword, options: 'i' }) },
        ])
      );
    }

    if (this._lastCreateTime) {
      conditions.push({ createdAt: db.command.lt(this._lastCreateTime) });
    }

    return conditions.length === 1 ? conditions[0] : db.command.and(conditions);
  },

  // 加载求职记录
  async loadApplications(refresh) {
    if (refresh) {
      this.setData({ loading: true, applications: [], hasMore: true });
      this._lastCreateTime = null;
    } else {
      this.setData({ loadingMore: true });
    }

    try {
      const query = applicationsCol.where(this._buildCondition()).orderBy('createdAt', 'desc').limit(PAGE_SIZE);
      const res = await query.get();
      const newApps = res.data;

      if (newApps.length < PAGE_SIZE) {
        this.setData({ hasMore: false });
      }

      if (newApps.length > 0) {
        this._lastCreateTime = newApps[newApps.length - 1].createdAt;
      }

      // 批量查询面试轮次
      const appIds = newApps.map(a => a._id);
      let roundsMap = {};

      if (appIds.length > 0) {
        const roundsRes = await roundsCol.where({
          applicationId: db.command.in(appIds)
        }).get();

        roundsRes.data.forEach(round => {
          if (!roundsMap[round.applicationId]) roundsMap[round.applicationId] = [];
          roundsMap[round.applicationId].push(round);
        });
      }

      let formatted = newApps.map(item => {
        const rounds = roundsMap[item._id] || [];
        const app = formatApplication(item);
        app.interviewRounds = rounds;
        app.processSteps = getProcessSteps(rounds, app.status);
        const status = getDynamicStatus(rounds, app.status);
        app.dynamicStatusText = status.text;
        app.dynamicStatus = status.type;
        app.dynamicTheme = getDynamicTheme(status.type);
        app.appliedDate = formatDateMD(item.appliedDate);
        app.isSelected = false;
        return app;
      });

      // 状态筛选
      const { activeTab } = this.data;
      if (activeTab !== 'all') {
        formatted = formatted.filter(app => app.dynamicStatus === activeTab);
      }

      const applications = refresh ? formatted : [...this.data.applications, ...formatted];
      this.setData({ applications, loading: false, loadingMore: false });
    } catch (err) {
      console.error('加载失败', err);
      this.setData({ loading: false, loadingMore: false });
      wx.showToast({ title: '加载失败', icon: 'none' });
    }
  },

  // 多选模式
  onLongPress(e) {
    if (this.data.isSelectMode) return;
    const index = e.currentTarget.dataset.index;
    const applications = this.data.applications;
    applications[index].isSelected = true;
    this.setData({
      isSelectMode: true,
      applications,
      selectedIds: [applications[index]._id],
      isAllSelected: false,
    });
  },

  onTapCard(e) {
    if (this.data.isSelectMode) {
      const index = e.currentTarget.dataset.index;
      const applications = this.data.applications;
      applications[index].isSelected = !applications[index].isSelected;
      const selectedIds = applications.filter(a => a.isSelected).map(a => a._id);
      this.setData({
        applications,
        selectedIds,
        isAllSelected: selectedIds.length === applications.length,
      });
    } else {
      this._needRefresh = true;
      wx.navigateTo({ url: `/pages/detail/index?id=${e.currentTarget.dataset.id}` });
    }
  },

  onSelectAll() {
    const isAllSelected = !this.data.isAllSelected;
    const applications = this.data.applications.map(app => ({ ...app, isSelected: isAllSelected }));
    this.setData({ applications, selectedIds: isAllSelected ? applications.map(a => a._id) : [], isAllSelected });
  },

  onCancelSelect() {
    const applications = this.data.applications.map(app => ({ ...app, isSelected: false }));
    this.setData({ isSelectMode: false, applications, selectedIds: [], isAllSelected: false });
  },

  onDeleteSelected() {
    const count = this.data.selectedIds.length;
    if (count === 0) return;

    wx.showModal({
      title: '确认删除',
      content: `确定要删除选中的 ${count} 条求职记录吗？删除后无法恢复。`,
      success: async (res) => {
        if (res.confirm) {
          wx.showLoading({ title: '删除中...' });
          try {
            await Promise.all(this.data.selectedIds.map(id => deleteApplication(id)));
            wx.hideLoading();
            wx.showToast({ title: `已删除 ${count} 条记录`, icon: 'success' });
            this.onCancelSelect();
            this.loadApplications(true);
          } catch (err) {
            wx.hideLoading();
            console.error('删除失败', err);
            wx.showToast({ title: '删除失败', icon: 'none' });
          }
        }
      },
    });
  },

  goToAdd() {
    if (this.data.isSelectMode) return;
    this._needRefresh = true;
    wx.navigateTo({ url: '/pages/add/index' });
  },
});
