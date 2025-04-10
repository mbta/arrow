import { defineConfig, globalIgnores } from "eslint/config"
import { fixupConfigRules, fixupPluginRules } from "@eslint/compat"
import typescriptEslint from "@typescript-eslint/eslint-plugin"
import preferArrow from "eslint-plugin-prefer-arrow"
import reactHooks from "eslint-plugin-react-hooks"
import _import from "eslint-plugin-import"
import jestDom from "eslint-plugin-jest-dom"
import globals from "globals"
import tsParser from "@typescript-eslint/parser"
import path from "node:path"
import { fileURLToPath } from "node:url"
import js from "@eslint/js"
import { FlatCompat } from "@eslint/eslintrc"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
})

export default defineConfig([
  globalIgnores([
    "**/webpack.config.js",
    "src/ReactPhoenix.js",
    "src/LiveReactPhoenix.js",
    "src/socket.js",
  ]),
  {
    extends: fixupConfigRules(
      compat.extends(
        "plugin:@typescript-eslint/recommended",
        "plugin:@typescript-eslint/recommended-requiring-type-checking",
        "plugin:react/recommended",
        "plugin:react-hooks/recommended",
        "plugin:jest-dom/recommended"
      )
    ),

    plugins: {
      "@typescript-eslint": fixupPluginRules(typescriptEslint),
      "prefer-arrow": preferArrow,
      "react-hooks": fixupPluginRules(reactHooks),
      import: fixupPluginRules(_import),
      "jest-dom": fixupPluginRules(jestDom),
    },

    languageOptions: {
      globals: {
        ...globals.browser,
      },

      parser: tsParser,
      ecmaVersion: 5,
      sourceType: "module",

      parserOptions: {
        project: "tsconfig.json",
      },
    },

    settings: {
      react: {
        version: "detect",
      },
    },

    rules: {
      "@typescript-eslint/array-type": "error",
      "@typescript-eslint/indent": "off",

      "@typescript-eslint/member-delimiter-style": [
        "off",
        {
          multiline: {
            delimiter: "none",
            requireLast: true,
          },

          singleline: {
            delimiter: "semi",
            requireLast: false,
          },
        },
      ],

      "@typescript-eslint/no-explicit-any": "off",
      "@typescript-eslint/no-parameter-properties": "off",
      "@typescript-eslint/no-use-before-define": "off",
      "@typescript-eslint/prefer-for-of": "error",
      "@typescript-eslint/prefer-function-type": "error",
      "@typescript-eslint/quotes": "off",
      "@typescript-eslint/semi": ["off", null],
      "@typescript-eslint/type-annotation-spacing": "off",
      "@typescript-eslint/unified-signatures": "error",
      "@typescript-eslint/explicit-function-return-type": "off",

      "@typescript-eslint/unbound-method": [
        "error",
        {
          ignoreStatic: true,
        },
      ],

      "arrow-parens": ["off", "as-needed"],
      "prefer-arrow/prefer-arrow-functions": "error",
      camelcase: "off",
      "comma-dangle": "off",
      complexity: "off",
      "constructor-super": "error",
      "dot-notation": "error",
      "eol-last": "off",
      eqeqeq: ["error", "smart"],
      "guard-for-in": "error",

      "id-blacklist": [
        "error",
        "any",
        "Number",
        "number",
        "String",
        "string",
        "Boolean",
        "boolean",
        "Undefined",
        "undefined",
      ],

      "react-hooks/exhaustive-deps": "error",
      "import/exports-last": "error",
      "import/group-exports": "error",
      "id-match": "error",
      "linebreak-style": "off",
      "max-classes-per-file": ["error", 1],
      "max-len": "off",
      "new-parens": "off",
      "newline-per-chained-call": "off",
      "no-bitwise": "error",
      "no-caller": "error",
      "no-cond-assign": "error",
      "no-console": "error",
      "no-debugger": "error",
      "no-empty": "error",
      "no-eval": "error",
      "no-extra-semi": "off",
      "no-fallthrough": "off",
      "no-invalid-this": "off",
      "no-irregular-whitespace": "off",
      "no-multiple-empty-lines": "off",
      "no-new-wrappers": "error",

      "no-shadow": [
        "error",
        {
          hoist: "all",
        },
      ],

      "no-throw-literal": "error",
      "no-trailing-spaces": "off",
      "no-undef-init": "error",
      "no-underscore-dangle": "error",
      "no-unsafe-finally": "error",
      "no-unused-expressions": "error",
      "no-unused-labels": "error",
      "object-shorthand": "error",
      "one-var": ["error", "never"],
      "quote-props": "off",
      radix: "error",
      "space-before-function-paren": "off",
      "space-in-parens": ["off", "never"],
      "spaced-comment": "error",
      "use-isnan": "error",
      "valid-typeof": "off",
    },
    ignores: [
      "webpack.config.js",
      "src/ReactPhoenix.js",
      "src/LiveReactPhoenix.js",
      "src/socket.js",
    ],
  },
])
