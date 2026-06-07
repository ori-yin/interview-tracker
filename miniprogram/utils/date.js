// 日期工具函数

// 格式化为 YYYY-MM-DD
function formatDateYMD(d) {
  if (typeof d === 'string') d = new Date(d);
  return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')}`;
}

// 格式化为 M月D日
function formatDateMD(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return `${d.getMonth() + 1}月${d.getDate()}日`;
}

// 格式化为 YYYY年M月D日
function formatDateChinese(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`;
}

// 格式化为 YYYY年M月D日 HH:mm
function formatDateTimeChinese(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日 ${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`;
}

// 获取今天的 YYYY-MM-DD
function getTodayYMD() {
  return formatDateYMD(new Date());
}

// 日期选择器
function pickDate(title, callback) {
  wx.showModal({
    title,
    editable: true,
    placeholderText: 'YYYY-MM-DD',
    success: (res) => {
      if (res.confirm && res.content) {
        callback(res.content);
      }
    }
  });
}

module.exports = { formatDateYMD, formatDateMD, formatDateChinese, formatDateTimeChinese, getTodayYMD, pickDate };
