import { defineConfig, Plugin } from "vite";
import solid from "vite-plugin-solid";
import fs from "fs";
import path from "path";

const configFileName = "app.json";

function assetsListPlugin(): Plugin {
  return {
    name: "assets-list", // 插件名称
    apply: "build", // 仅在构建时应用
    closeBundle() {
      const distDir = path.resolve(__dirname, "dist"); // 输出目录
      const files: string[] = [];
      const appConfig = JSON.parse(
        fs.readFileSync(path.resolve(__dirname, configFileName), "utf-8")
      );

      // 递归地读取所有文件
      function readFiles(directory: string) {
        fs.readdirSync(directory).forEach((file: string) => {
          const fullPath = path.join(directory, file);
          if (fs.statSync(fullPath).isDirectory()) {
            readFiles(fullPath); // 如果是目录，则递归读取
          } else {
            files.push(
              fullPath.replace(distDir + path.sep, "").replaceAll(path.sep, "/")
            ); // 保存文件路径，移除目录前缀
          }
        });
      }

      readFiles(distDir);
      appConfig["files"] = files;
      // 在这里你可以选择将文件列表写入到某个文件
      // 例如:
      fs.writeFileSync(
        path.join(distDir, configFileName),
        JSON.stringify(appConfig, null, 2)
      );

      console.log("Generated Files:", files);
    },
  };
}

export default defineConfig({
  plugins: [
    solid({
      solid: {
        moduleName: "solid-native",
        generate: "universal",
      },
    }),
    assetsListPlugin(),
  ],
  build: {
    minify: false,
    // modulePreload: false,
    rollupOptions: {
      output: {
        entryFileNames: `[name].js`,
        chunkFileNames: `[name].js`,
        assetFileNames: `assets/[name].[ext]`,
        format: "iife",
      },
      input: ["src/index.tsx"],
      // plugins: [
      //   {
      //     name: "watch-external",
      //     buildStart() {
      //       this.addWatchFile(path.resolve(__dirname, configFileName));
      //     },
      //   },
      // ],
    },
    // sourcemap: true,
    // watch: {},
  },
  server: {
    host: "0.0.0.0",
  },
  preview: {
    port: 5050,
  },
});
