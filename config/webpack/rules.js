const MiniCssExtractPlugin = require("mini-css-extract-plugin");

// PostCSS plugins.
const nested = require("postcss-nested");
const autoprefixer = require("autoprefixer");

const commonRules = [
  {
    test: /\.(jpg|jpeg|png|gif|eps|sketch|eot|ttf|woff|woff2|svg|pdf)/,
    use: [
      {
        loader: "file-loader",
        options: {
          name: "[name].[hash].[ext]",
          context: "app/assets"
        }
      }
    ]
  },
  {
    test: /\.js$/,
    exclude: /rails-ujs/,
    use: [
      {
        loader: "babel-loader"
      }
    ]
  }
];

const prodRules = [
  {
    test: /\.css$/,
    use: [
      MiniCssExtractPlugin.loader,
      {
        loader: "css-loader"
      },
      {
        loader: "postcss-loader",
        options: {
          sourceMap: true,
          plugins() {
            return [nested, autoprefixer];
          }
        }
      }
    ]
  }
];

const devRules = [
  {
    test: /\.css$/,
    use: [
      {
        loader: "style-loader"
      },
      {
        loader: "css-loader",
        options: {
          sourceMap: true
        }
      },
      {
        loader: "postcss-loader",
        options: {
          sourceMap: true,
          plugins() {
            return [nested, autoprefixer];
          }
        }
      }
    ]
  }
];

module.exports = function(deployTarget) {
  // Collect correct rules for environment.
  let rules = commonRules;
  if (deployTarget) {
    rules = rules.concat(prodRules);
  } else {
    rules = rules.concat(devRules);
  }

  return rules;
};
