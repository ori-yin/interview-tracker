// 添加求职记录
const { db, applicationsCol } = require('../../utils/db');
const { getTodayYMD } = require('../../utils/date');

Page({
  data: {
    companyName: '',
    positionName: '',
    appliedDate: '',
    location: '',
    salaryRange: '',
    notes: '',
    showValidation: false,
  },

  onLoad() {
    this.setData({ appliedDate: getTodayYMD() });
  },

  onInput(e) {
    const field = e.currentTarget.dataset.field;
    this.setData({ [field]: e.detail.value });
  },

  onDateChange(e) {
    this.setData({ appliedDate: e.detail.value });
  },

  async onSave() {
    if (!this.data.companyName.trim() || !this.data.positionName.trim()) {
      this.setData({ showValidation: true });
      wx.showToast({ title: '请填写必填信息', icon: 'none' });
      return;
    }

    wx.showLoading({ title: '保存中...' });
    try {
      await applicationsCol.add({
        data: {
          companyName: this.data.companyName.trim(),
          positionName: this.data.positionName.trim(),
          status: 'applied',
          appliedDate: this.data.appliedDate,
          location: this.data.location.trim() || null,
          salaryRange: this.data.salaryRange.trim() || null,
          notes: this.data.notes.trim() || null,
          createdAt: db.serverDate(),
          updatedAt: db.serverDate(),
        },
      });
      wx.hideLoading();
      wx.showToast({ title: '添加成功', icon: 'success' });
      setTimeout(() => wx.navigateBack(), 800);
    } catch (err) {
      wx.hideLoading();
      console.error('添加失败', err);
      wx.showToast({ title: '添加失败', icon: 'none' });
    }
  },
});
