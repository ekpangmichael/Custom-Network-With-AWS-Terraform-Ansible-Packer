#!/bin/bash

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN INSTANCE, THEN TRIGGER A PROVISIONER
# This script configures webpack.prod.js file
# ---------------------------------------------------------------------------------------------------------------------

# ensures the script terminate when it encounters an error
set -o pipefail

blue=`tput setaf 4`
green=`tput setaf 2`
reset=`tput sgr0`

#function to display messages as the script executes
echo_message() {
  echo  -e "\n ${1}=================================== ${2} ============================================ ${reset} \n "
}



#configure the webpack file and update the server url
configure_webpack(){
echo_message "${blue}" "Setting up webpack file"
 cd selene-ah-frontend
 cd config
  sudo rm webpack.prod.js
  sudo touch webpack.prod.js
  sudo chmod 777 webpack.prod.js
  echo "const merge = require('webpack-merge'); // Merge our base and dev config files.
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyWebpackPlugin = require('uglifyjs-webpack-plugin');
const common = require('./webpack.base');
const webpack = require('webpack');
const OptimizeCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');

// SCSS test regex 
const scssTest = /\.scss$/;

const uglifyJS = new UglifyWebpackPlugin({
  test: /\.(js|jsx)$/,
  exclude: /node_modules/,
  cache: true,
  parallel: true,
});

// Webapck exports 
module.exports = merge(common, {
  mode: 'production',
  devtool: 'source-map',
  module: {
    rules: [
      {
        test: scssTest,
        use: ['style-loader', 'css-loader', 'sass-loader'],
      },
    ],
  },
  optimization: {
    minimizer: [uglifyJS],
    splitChunks: {
      cacheGroups: {
        styles: {
          name: 'styles',
          test: scssTest,
          chunks: 'all',
          enforce: true,
        },
      },
    },
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name].[hash].css',
      chunkFilename: '[id].[hash].css',
    }),
    new OptimizeCssAssetsPlugin({}),
    uglifyJS,
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production'),
      'process.env.SERVER_API': JSON.stringify('http://$BACKEND_IP/api/v1'),
      'process.env.GOOGLE_URL':JSON.stringify('https://selene-ah-staging.herokuapp.com/api/v1/auth/google'),
      'process.env.FACEBOOK_URL': JSON.stringify('https://selene-ah-staging.herokuapp.com/api/v1/auth/facebook'),
      'process.env.TWITTER_URL':JSON.stringify('https://selene-ah-staging.herokuapp.com/api/v1/auth/twitter'),
      'process.env.BASE_URL': JSON.stringify('https://selene-ah-staging.herokuapp.com/api/v1/auth/'),
      'process.env.CLOUDINARY_API_BASE_URL': JSON.stringify('https://api.cloudinary.com/v1_1/dsozu5ads/upload'),
      'process.env.CLOUDINARY_UPLOAD_PRESET': JSON.stringify('zklk2cjx'),
      'process.env.FRONTEND_API': JSON.stringify('https://selene-front-production.herokuapp.com'),
      'process.env.DEFAULT_IMAGE_URL': JSON.stringify('https://res.cloudinary.com/dsozu5ads/image/upload/v1548068649/robot.svg')
    }),
  ],
});
" >> webpack.prod.js
echo_message "${green}" "Webpack setup completed successfully"
echo_message "${blue}" "Building the application"
cd ..
sudo npm run build
echo_message "${green}" "Build complete"
}

#runs all functions
main(){
  configure_webpack
}

main
