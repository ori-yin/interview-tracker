App({
  onLaunch() {
    if (!wx.cloud) {
      console.error('请使用 2.2.3 或以上的基础库以使用云能力');
    } else {
      wx.cloud.init({
        env: 'cloud1-d1g5mm7wgdd81379d',
        traceUser: true,
      });
    }
    // 优先从本地缓存读取，缓存未命中再调云函数
    this._openid = wx.getStorageSync('openid') || '';
    this._openidReady = this._openid
      ? Promise.resolve(this._openid)
      : this._fetchOpenid();
  },

  _fetchOpenid() {
    return new Promise((resolve) => {
      wx.cloud.callFunction({
        name: 'login',
        success: (res) => {
          this._openid = res.result.openid || '';
          if (this._openid) wx.setStorageSync('openid', this._openid);
          resolve(this._openid);
        },
        fail: (err) => {
          console.error('获取 openid 失败', err);
          resolve('');
        },
      });
    });
  },

  globalData: {}
});
