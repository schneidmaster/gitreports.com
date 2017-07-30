export default function(target) {
  let deployTarget, namePattern, cssNamePattern;
  if (target === 'production' || target === 'staging') {
    deployTarget = true;
    namePattern = '[name]-[chunkhash]';
    cssNamePattern = '[name]-[contenthash]';
  } else {
    deployTarget = false;
    namePattern = '[name]';
    cssNamePattern = '[name]';
  }

  return { deployTarget, namePattern, cssNamePattern };
};
