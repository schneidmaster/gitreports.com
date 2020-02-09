let liveReload;
const devServerPort = 3808;
if (!process.env.NO_LIVE_RELOAD) {
  liveReload = true;
}
const publicHost = process.env.WEBPACK_DEV_HOST || "lvh.me";

module.exports.devServer = {
  host: publicHost,
  port: devServerPort,
  headers: { "Access-Control-Allow-Origin": "*" },
  hot: liveReload,
  inline: liveReload
};

module.exports.publicPath = `http://${publicHost}:${devServerPort}/assets/`;
