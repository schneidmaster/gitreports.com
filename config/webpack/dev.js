let liveReload;
const devServerPort = 3808;
if (!process.env.NO_LIVE_RELOAD) { liveReload = true; }
const publicHost = process.env.WEBPACK_DEV_HOST || 'lvh.me';

export const devServer = {
  host: publicHost,
  port: devServerPort,
  headers: { 'Access-Control-Allow-Origin': '*' },
  hot: liveReload,
  inline: liveReload,
};

export const publicPath = `http://${publicHost}:${devServerPort}/assets/`;
