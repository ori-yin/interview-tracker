// 详情页
const { applicationsCol, roundsCol, deleteApplication } = require('../../utils/db');
const { formatDateChinese, formatDateTimeChinese } = require('../../utils/date');
const { formatApplication, formatRound, getDynamicTheme } = require('../../utils/constants');

Page({
  data: {
    application: null,
    interviewRounds: [],
    applicationId: '',
  },

  onLoad(options) {
    this.setData({ applicationId: options.id });
  },

  onShow() {
    this.loadDetail();
  },

  async loadDetail() {
    try {
      const res = await applicationsCol.doc(this.data.applicationId).get();
      const application = formatApplication(res.data);
      application.appliedDateFull = formatDateChinese(res.data.appliedDate);

      const roundsRes = await roundsCol
        .where({ applicationId: this.data.applicationId })
        .orderBy('interviewDate', 'desc')
        .get();
      const interviewRounds = roundsRes.data.map(r => {
        const formatted = formatRound(r);
        formatted.interviewDateFull = formatDateTimeChinese(r.interviewDate);
        return formatted;
      });

      this.setData({ application, interviewRounds });
    } catch (err) {
      console.error('加载详情失败', err);
      wx.showToast({ title: '加载失败', icon: 'none' });
    }
  },

  goToAddRound() {
    wx.navigateTo({ url: `/pages/add-round/index?id=${this.data.applicationId}` });
  },

  goToEdit() {
    wx.navigateTo({ url: `/pages/edit/index?id=${this.data.applicationId}` });
  },

  onRoundTap(e) {
    const round = this.data.interviewRounds[e.currentTarget.dataset.index];
    wx.showActionSheet({
      itemList: ['删除此轮面试'],
      success: (res) => {
        if (res.tapIndex === 0) {
          wx.showModal({
            title: '确认删除',
            content: '确定要删除这轮面试记录吗？',
            success: async (modalRes) => {
              if (modalRes.confirm) {
                try {
                  await roundsCol.doc(round._id).remove();
                  wx.showToast({ title: '已删除', icon: 'success' });
                  this.loadDetail();
                } catch (err) {
                  wx.showToast({ title: '删除失败', icon: 'none' });
                }
              }
            },
          });
        }
      },
    });
  },

  onDeleteApplication() {
    wx.showModal({
      title: '确认删除',
      content: '确定要删除这条求职记录吗？删除后无法恢复。',
      success: async (res) => {
        if (res.confirm) {
          try {
            await deleteApplication(this.data.applicationId);
            wx.showToast({ title: '已删除', icon: 'success' });
            wx.navigateBack();
          } catch (err) {
            wx.showToast({ title: '删除失败', icon: 'none' });
          }
        }
      },
    });
  },
});
