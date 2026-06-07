// 添加面试轮次
const { db, applicationsCol, roundsCol } = require('../../utils/db');
const { getTodayYMD } = require('../../utils/date');
const { RESULT_MAP } = require('../../utils/constants');

Page({
  data: {
    applicationId: '',
    roundName: '',
    interviewDate: '',
    interviewer: '',
    result: 'pending',
    feedback: '',
    showValidation: false,
    presetNames: ['一面', '二面', '三面', '交叉面', 'HR面', '笔试', 'Offer'],
    resultOptions: Object.keys(RESULT_MAP).map(value => ({ value, label: RESULT_MAP[value] })),
  },

  onLoad(options) {
    this.setData({
      applicationId: options.id,
      interviewDate: getTodayYMD(),
    });
  },

  onInput(e) {
    const field = e.currentTarget.dataset.field;
    this.setData({ [field]: e.detail.value });
  },

  onDateChange(e) {
    this.setData({ interviewDate: e.detail.value });
  },

  onPresetTap(e) {
    this.setData({ roundName: e.currentTarget.dataset.name });
  },

  onResultChange(e) {
    this.setData({ result: e.detail.value });
  },

  async onSave() {
    if (!this.data.roundName.trim()) {
      this.setData({ showValidation: true });
      wx.showToast({ title: '请输入轮次名称', icon: 'none' });
      return;
    }

    wx.showLoading({ title: '保存中...' });
    try {
      await roundsCol.add({
        data: {
          applicationId: this.data.applicationId,
          roundName: this.data.roundName.trim(),
          interviewDate: this.data.interviewDate,
          interviewer: this.data.interviewer.trim() || null,
          result: this.data.result,
          feedback: this.data.feedback.trim() || null,
          createdAt: db.serverDate(),
        },
      });

      await applicationsCol.doc(this.data.applicationId).update({
        data: { updatedAt: db.serverDate() },
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
