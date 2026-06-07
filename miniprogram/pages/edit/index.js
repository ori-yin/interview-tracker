// 编辑求职记录
const { db, applicationsCol } = require('../../utils/db');
const { formatDateYMD } = require('../../utils/date');
const { STATUS_MAP } = require('../../utils/constants');

const statusValues = Object.keys(STATUS_MAP);
const statusLabels = Object.values(STATUS_MAP);

Page({
  data: {
    loaded: false,
    applicationId: '',
    companyName: '',
    positionName: '',
    status: 'applied',
    appliedDate: '',
    location: '',
    salaryRange: '',
    notes: '',
    statusOptions: statusValues.map((value, index) => ({ value, label: statusLabels[index] })),
  },

  onLoad(options) {
    this.setData({ applicationId: options.id });
    this.loadApplication();
  },

  async loadApplication() {
    try {
      const res = await applicationsCol.doc(this.data.applicationId).get();
      const app = res.data;
      this.setData({
        loaded: true,
        companyName: app.companyName,
        positionName: app.positionName,
        status: app.status,
        appliedDate: formatDateYMD(app.appliedDate),
        location: app.location || '',
        salaryRange: app.salaryRange || '',
        notes: app.notes || '',
      });
    } catch (err) {
      console.error('加载失败', err);
      wx.showToast({ title: '加载失败', icon: 'none' });
    }
  },

  onInput(e) {
    const field = e.currentTarget.dataset.field;
    this.setData({ [field]: e.detail.value });
  },

  onDateChange(e) {
    this.setData({ appliedDate: e.detail.value });
  },

  onStatusChange(e) {
    this.setData({ status: e.detail.value });
  },

  async onSave() {
    if (!this.data.companyName.trim() || !this.data.positionName.trim()) {
      wx.showToast({ title: '请填写公司和岗位名称', icon: 'none' });
      return;
    }

    wx.showLoading({ title: '保存中...' });
    try {
      await applicationsCol.doc(this.data.applicationId).update({
        data: {
          companyName: this.data.companyName.trim(),
          positionName: this.data.positionName.trim(),
          status: this.data.status,
          appliedDate: this.data.appliedDate,
          location: this.data.location.trim() || null,
          salaryRange: this.data.salaryRange.trim() || null,
          notes: this.data.notes.trim() || null,
          updatedAt: db.serverDate(),
        },
      });
      wx.hideLoading();
      wx.showToast({ title: '保存成功', icon: 'success' });
      setTimeout(() => wx.navigateBack(), 800);
    } catch (err) {
      wx.hideLoading();
      console.error('保存失败', err);
      wx.showToast({ title: '保存失败', icon: 'none' });
    }
  },
});
