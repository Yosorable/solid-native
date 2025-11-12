import { defineConfig } from "vite";
import solid from "vite-plugin-solid";

export default defineConfig({
  plugins: [
    solid({
      solid: {
        moduleName: "solid-native",
        generate: "universal",
        hydratable: false,
      },
    }),
  ],
  build: {
    lib: {
      entry: "src/index.ts",
      name: "SolidNative",
      fileName: (fmt) => `sdk${fmt === "es" ? ".es" : ""}.js`,
      formats: ["es", "iife"],
    },
  },
});
