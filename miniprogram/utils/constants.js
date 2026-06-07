// 状态映射
const STATUS_MAP = {
  applied: '已投递',
  writtenTest: '笔试',
  interviewing: '面试中',
  offer: 'Offer',
  rejected: '已拒绝',
  failed: '未通过',
};

// 结果映射
const RESULT_MAP = {
  pending: '待定',
  passed: '通过',
  failed: '未通过',
  cancelled: '已取消',
};

// 状态主题映射（TDesign tag theme）
const STATUS_THEME = {
  applied: 'default',
  writtenTest: 'warning',
  interviewing: 'warning',
  offer: 'success',
  rejected: 'default',
  failed: 'danger',
};

// 动态状态主题
function getDynamicTheme(dynamicStatus) {
  if (dynamicStatus === 'passed') return 'success';
  if (dynamicStatus === 'failed') return 'danger';
  return 'warning';
}

// 格式化求职记录
function formatApplication(item) {
  return {
    ...item,
    statusText: STATUS_MAP[item.status] || item.status,
    statusTheme: STATUS_THEME[item.status] || 'default',
  };
}

// 格式化面试轮次
function formatRound(item) {
  return {
    ...item,
    resultText: RESULT_MAP[item.result] || item.result,
  };
}

// 计算流程步骤
function getProcessSteps(interviewRounds, status) {
  const steps = [];
  const rounds = interviewRounds || [];

  const hasOfferPassed = rounds.some(r =>
    r.roundName.toLowerCase().includes('offer') && r.result === 'passed'
  );
  const hasFailed = rounds.some(r => r.result === 'failed' || r.result === 'cancelled');
  const isApplicationFailed = status === 'failed';

  const sorted = [...rounds].sort((a, b) => new Date(a.interviewDate) - new Date(b.interviewDate));
  const hasNextStep = status === 'writtenTest' || sorted.length > 0;
  steps.push({ name: '已投递', dotClass: 'step-done', lineClass: hasNextStep ? 'line-done' : '' });

  if (status === 'writtenTest') {
    steps.push({ name: '笔试', dotClass: 'step-done', lineClass: sorted.length > 0 ? 'line-done' : '' });
  }

  sorted.forEach((round, index) => {
    const isLast = index === sorted.length - 1;
    const isFailed = isLast && (hasFailed || isApplicationFailed);
    const isOffer = isLast && hasOfferPassed;

    let dotClass = 'step-done';
    let lineClass = 'line-done';
    if (isFailed) { dotClass = 'step-failed'; lineClass = 'line-failed'; }
    else if (isOffer) { dotClass = 'step-offer'; lineClass = 'line-done'; }
    else if (isLast) { dotClass = 'step-current'; lineClass = 'line-current'; }

    steps.push({
      name: round.roundName || `第${index + 1}面`,
      dotClass,
      lineClass: index < sorted.length - 1 ? lineClass : '',
    });
  });

  if (sorted.length === 0 && status !== 'applied') {
    const dotClass = isApplicationFailed ? 'step-failed' : 'step-current';
    steps.push({ name: '待面试', dotClass, lineClass: '' });
  }

  return steps;
}

// 计算动态状态
function getDynamicStatus(interviewRounds, status) {
  const rounds = interviewRounds || [];
  const hasOfferPassed = rounds.some(r =>
    r.roundName.toLowerCase().includes('offer') && r.result === 'passed'
  );
  const hasFailed = rounds.some(r => r.result === 'failed' || r.result === 'cancelled');

  if (hasOfferPassed) return { text: '已通过', type: 'passed' };
  if (hasFailed || status === 'failed') return { text: '已拒绝', type: 'failed' };
  return { text: '流程中', type: 'interviewing' };
}

module.exports = {
  STATUS_MAP, RESULT_MAP, STATUS_THEME,
  getDynamicTheme, formatApplication, formatRound,
  getProcessSteps, getDynamicStatus,
};
