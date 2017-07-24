let liveReload;
let devServerPort = 3808;
if (!process.env.NO_LIVE_RELOAD) { liveReload = true; }
let publicHost = process.env.WEBPACK_DEV_HOST || 'lvh.me';

export let devServer = {
  host: publicHost,
  port: devServerPort,
  headers: { 'Access-Control-Allow-Origin': '*' },
  hot: liveReload,
  inline: liveReload
};

export let publicPath = `http://${publicHost}:${devServerPort}/assets/`;
