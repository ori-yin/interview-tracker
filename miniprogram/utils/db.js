// 数据库初始化
const db = wx.cloud.database();
const applicationsCol = db.collection('applications');
const roundsCol = db.collection('interviewRounds');

// 删除求职记录及其所有面试轮次
async function deleteApplication(id) {
  const roundsRes = await roundsCol.where({ applicationId: id }).get();
  await Promise.all(roundsRes.data.map(r => roundsCol.doc(r._id).remove()));
  await applicationsCol.doc(id).remove();
}

module.exports = { db, applicationsCol, roundsCol, deleteApplication };
