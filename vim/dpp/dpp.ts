import {
  BaseConfig,
  ContextBuilder,
  Dpp,
  Plugin,
} from "https://deno.land/x/dpp_vim@v0.0.5/types.ts";
import { Denops, fn } from "https://deno.land/x/dpp_vim@v0.0.5/deps.ts";

export class Config extends BaseConfig {
  override async config(args: {
    denops: Denops;
    contextBuilder: ContextBuilder;
    basePath: string;
    dpp: Dpp;
  }): Promise<{
    plugins: Plugin[];
    stateLines: string[];
  }> {
    args.contextBuilder.setGlobal({
      protocols: ["git"],
    });

    type Toml = {
      hooks_file?: string;
      ftplugins?: Record<string, string>;
      plugins?: Plugin[];
    };

    type LazyMakeStateResult = {
      plugins: Plugin[];
      stateLines: string[];
    };

    const [context, options] = await args.contextBuilder.get(args.denops);
    const dotfilesDir = "~/dotfiles/vim/dpp/tomls/";

    const tomls: Toml[] = [];
    tomls.push(
      await args.dpp.extAction(
        args.denops,
        context,
        options,
        "toml",
        "load",
        {
          path: await fn.expand(args.denops, dotfilesDir + "dpp.toml"),
          options: {
            lazy: false,
          },
        },
      ) as Toml,
    );

    tomls.push(
      await args.dpp.extAction(
        args.denops,
        context,
        options,
        "toml",
        "load",
        {
          path: await fn.expand(args.denops, dotfilesDir + "dpp_lsp.toml"),
          options: {
            lazy: false,
          },
        },
      ) as Toml,
    );

    tomls.push(
      await args.dpp.extAction(
        args.denops,
        context,
        options,
        "toml",
        "load",
        {
          path: await fn.expand(args.denops, dotfilesDir + "dpp_treesitter.toml"),
          options: {
            lazy: false,
          },
        },
      ) as Toml,
    );


    tomls.push(
      await args.dpp.extAction(
        args.denops,
        context,
        options,
        "toml",
        "load",
        {
          path: await fn.expand(args.denops, dotfilesDir + "dpp_lazy.toml"),
          options: {
            lazy: true,
          },
        },
      ) as Toml,
    );

    tomls.push(
      await args.dpp.extAction(
        args.denops,
        context,
        options,
        "toml",
        "load",
        {
          path: await fn.expand(args.denops, dotfilesDir + "dpp_lazy_ddc.toml"),
          options: {
            lazy: true,
          },
        },
      ) as Toml,
    );

    const recordPlugins: Record<string, Plugin> = {};
    const ftplugins: Record<string, string> = {};
    const hooksFiles: string[] = [];

    tomls.forEach((toml) => {

      for (const plugin of toml.plugins) {
        recordPlugins[plugin.name] = plugin;
      }

      if (toml.ftplugins) {
        for (const filetype of Object.keys(toml.ftplugins)) {
          if (ftplugins[filetype]) {
            ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
          } else {
            ftplugins[filetype] = toml.ftplugins[filetype];
          }
        }
      }

      if (toml.hooks_file) {
        hooksFiles.push(toml.hooks_file);
      }
    });

    const lazyResult = await args.dpp.extAction(
      args.denops,
      context,
      options,
      "lazy",
      "makeState",
      {
        plugins: Object.values(recordPlugins),
      },
    ) as LazyMakeStateResult;

    return {
      plugins: lazyResult.plugins,
      stateLines: lazyResult.stateLines,
    };
  }
}
// ================================================================================================
// import {
//   BaseConfig,
//   ConfigReturn,
//   ContextBuilder,
//   Dpp,
//   Plugin,
// } from "https://deno.land/x/dpp_vim@v0.1.0/types.ts";
// import { Denops, fn } from "https://deno.land/x/dpp_vim@v0.1.0/deps.ts";
// 
// type Toml = {
//   hooks_file?: string;
//   ftplugins?: Record<string, string>;
//   plugins?: Plugin[]
// };
// 
// type LazyMakeStateResult = {
//   plugins: Plugin[];
//   stateLines: string[];
// };
// 
// export class Config extends BaseConfig {
//   override async config(args: {
//     denops: Denops;
//     contextBuilder: ContextBuilder;
//     basePath: string;
//     dpp: Dpp;
//   }): Promise<ConfigReturn> {
// 
// 
//     const [context, options] = await args.contextBuilder.get(args.denops);
// 
//     const tomlPromises = [
//       { path: "~/dotfiles/vim/rc/dein.toml", lazy: false },
//       // { path: "~/dotfiles/vim/rc/dein_lsp.toml", lazy: false },
//       { path: "~/dotfiles/vim/rc/dein_treesitter.toml", lazy: false },
//       { path: "~/dotfiles/vim/rc/dein_lazy.toml", lazy: true },
//       { path: "~/dotfiles/vim/rc/dein_lazy_ddc.toml", lazy: true },
//     ].map((tomlFile) =>
//       args.dpp.extAction(
//         args.denops,
//         context,
//         options,
//         'toml',
//         'load',
//         {
//           path: tomlFile.path,
//           options: {
//             lazy: tomlFile.lazy,
//           },
//         },
//       ) as Promise<Toml | undefined>
//     );
// 
//     const tomls: (Toml | undefined)[] = await Promise.all(tomlPromises);
// 
//     const recordPlugins: Record<string, Plugin> = {};
//     const ftplugins: Record<string, string> = {};
//     const hooksFiles: string[] = [];
// 
//     for (const toml of tomls) {
//       if (!toml) {
//         continue;
//       }
// 
//       for (const plugin of toml.plugins ?? []) {
//         recordPlugins[plugin.name] = plugin;
//       }
// 
//       if (toml.ftplugins) {
//         for (const filetype of Object.keys(toml.ftplugins)) {
//           if (ftplugins[filetype]) {
//             ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
//           } else {
//             ftplugins[filetype] = toml.ftplugins[filetype];
//           }
//         }
//       }
// 
//       if (toml.hooks_file) {
//         hooksFiles.push(toml.hooks_file);
//       }
//     }
// 
//     const lazyResult = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       'lazy',
//       'make_state',
//       {
//         plugins: Object.values(recordPlugins),
//       },
//     ) as LazyMakeStateResult | undefined;
// 
//     return {
//       ftplugins,
//       hooksFiles,
//       plugins: lazyResult?.plugins ?? [],
//       stateLines: lazyResult?.stateLines ?? [],
//     }
//   }
// }


// ================================================================================================
// import {
//   BaseConfig,
//   ContextBuilder,
//   Dpp,
//   Plugin,
// } from "https://deno.land/x/dpp_vim@v0.0.2/types.ts";
// import { Denops, fn } from "https://deno.land/x/dpp_vim@v0.0.2/deps.ts";
// 
// export class Config extends BaseConfig {
//   override async config(args: {
//     denops: Denops;
//     contextBuilder: ContextBuilder;
//     basePath: string;
//     dpp: Dpp;
//   }): Promise<{
//     plugins: Plugin[];
//     stateLines: string[];
//   }> {
//     args.contextBuilder.setGlobal({
//       protocols: ["git"],
//     });
// 
//     const [context, options] = await args.contextBuilder.get(args.denops);
// 
//     const dotfilesDir = '~/dotfiles/vim/rc';
// 
//     const normalPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein.toml"),
//         options: { },
//       },
//     ) as Plugin[];
// 
//     const lazyPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein_lazy.toml"),
//         options: {
//           lazy: true,
//         },
//       },
//     ) as Plugin[];
// 
//     const lspPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein_lsp.toml"),
//         options: {
//           lazy: false,
//         },
//       },
//     ) as Plugin[];
// 
//     const treesitterPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein_treesitter.toml"),
//         options: {
//           lazy: false,
//         },
//       },
//     ) as Plugin[];
// 
//     const ddcPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein_lazy_ddc.toml"),
//         options: {
//           lazy: true,
//         },
//       },
//     ) as Plugin[];
// 
//     const recordPlugins: Record<string, Plugin> = {};
// 
//     for (const plugin of normalPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     for (const plugin of lazyPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     for (const plugin of lspPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     for (const plugin of treesitterPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     for (const plugin of ddcPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     const stateLines = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "lazy",
//       "makeState",
//       {
//         plugins: Object.values(recordPlugins),
//       },
//     ) as string[];
// 
//     return {
//       plugins: Object.values(recordPlugins),
//       stateLines,
//     };
//   }
// }


// ================================================================================================
// import {
//   BaseConfig,
//   ContextBuilder,
//   Dpp,
//   Plugin,
// } from "https://deno.land/x/dpp_vim@v0.0.5/types.ts";
// import { Denops, fn } from "https://deno.land/x/dpp_vim@v0.0.5/deps.ts";
// 
// export class Config extends BaseConfig {
//   override async config(args: {
//     denops: Denops;
//     contextBuilder: ContextBuilder;
//     basePath: string;
//     dpp: Dpp;
//   }): Promise<{
//     plugins: Plugin[];
//     stateLines: string[];
//   }> {
//     args.contextBuilder.setGlobal({
//       protocols: ["git"],
//     });
// 
//     type Toml = {
//       hooks_file?: string;
//       ftplugins?: Record<string, string>;
//       plugins?: Plugin[];
//     };
// 
//     type LazyMakeStateResult = {
//       plugins: Plugin[];
//       stateLines: string[];
//     };
// 
//     const [context, options] = await args.contextBuilder.get(args.denops);
//     const dotfilesDir = "~/dotfiles/vim/rc/";
// 
//     const tomls: Toml[] = [];
//     tomls.push(
//       await args.dpp.extAction(
//         args.denops,
//         context,
//         options,
//         "toml",
//         "load",
//         {
//           path: await fn.expand(args.denops, dotfilesDir + "dein.toml"),
//           options: {
//             lazy: false,
//           },
//         },
//       ) as Toml,
//     );
// 
//     tomls.push(
//       await args.dpp.extAction(
//         args.denops,
//         context,
//         options,
//         "toml",
//         "load",
//         {
//           path: await fn.expand(args.denops, dotfilesDir + "dein_lazy.toml"),
//           options: {
//             lazy: true,
//           },
//         },
//       ) as Toml,
//     );
// 
//     const recordPlugins: Record<string, Plugin> = {};
//     const ftplugins: Record<string, string> = {};
//     const hooksFiles: string[] = [];
// 
//     tomls.forEach((toml) => {
// 
//       for (const plugin of toml.plugins) {
//         recordPlugins[plugin.name] = plugin;
//       }
// 
//       if (toml.ftplugins) {
//         for (const filetype of Object.keys(toml.ftplugins)) {
//           if (ftplugins[filetype]) {
//             ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
//           } else {
//             ftplugins[filetype] = toml.ftplugins[filetype];
//           }
//         }
//       }
// 
//       if (toml.hooks_file) {
//         hooksFiles.push(toml.hooks_file);
//       }
//     });
// 
//     const lazyResult = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "lazy",
//       "makeState",
//       {
//         plugins: Object.values(recordPlugins),
//       },
//     ) as LazyMakeStateResult;
// 
//     console.log(lazyResult);
// 
//     return {
//       plugins: lazyResult.plugins,
//       stateLines: lazyResult.stateLines,
//     };
//   }
// }



// ================================================================================================
// import {
//   BaseConfig,
//   ContextBuilder,
//   Dpp,
//   Plugin,
// } from "https://deno.land/x/dpp_vim@v0.0.7/types.ts";
// import { Denops, fn } from "https://deno.land/x/dpp_vim@v0.0.7/deps.ts";
// 
// 
// export class Config extends BaseConfig {
//   override async config(args: {
//     denops: Denops;
//     contextBuilder: ContextBuilder;
//     basePath: string;
//     dpp: Dpp;
//   }): Promise<{
//     plugins: Plugin[];
//     stateLines: string[];
//   }> {
//     args.contextBuilder.setGlobal({
//       protocols: ["git"],
//     });
// 
//     const [context, options] = await args.contextBuilder.get(args.denops);
// 
//     const dotfilesDir = '~/dotfiles/vim/rc';
// 
//     const normalPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein.toml"),
//         options: { },
//       },
//     ) as Plugin[];
// 
//     const lazyPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein_lazy.toml"),
//         options: {
//           lazy: true,
//         },
//       },
//     ) as Plugin[];
// 
//     const lspPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein_lsp.toml"),
//         options: {
//           lazy: false,
//         },
//       },
//     ) as Plugin[];
// 
//     const ddcPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein_lazy_ddc.toml"),
//         options: {
//           lazy: true,
//         },
//       },
//     ) as Plugin[];
// 
//     const treesitterPlugins = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "toml",
//       "load",
//       {
//         path: await fn.expand(args.denops, dotfilesDir + "/dein_lazy_treesitter.toml"),
//         options: {
//           lazy: true,
//         },
//       },
//     ) as Plugin[];
// 
//     const recordPlugins: Record<string, Plugin> = {};
//     for (const plugin of normalPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     for (const plugin of lazyPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     for (const plugin of lspPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     for (const plugin of ddcPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     for (const plugin of treesitterPlugins) {
//       recordPlugins[plugin.name] = plugin;
//     }
// 
//     const stateLines = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "lazy",
//       "makeState",
//       {
//         plugins: Object.values(recordPlugins),
//       },
//     ) as string[];
// 
//     return {
//       plugins: Object.values(recordPlugins),
//       stateLines,
//     };
//   }
// }
//


// ================================================================================================
// import {
//   BaseConfig,
//   ConfigArguments,
//   ConfigReturn,
//   Plugin,
// } from "https://deno.land/x/dpp_vim@v0.0.7/types.ts";
// import { fn } from "https://deno.land/x/dpp_vim@v0.0.7/deps.ts";
// 
// // dpp-ext-toml
// type Toml = {
//   hooks_file?: string;
//   ftplugins?: Record<string, string>;
//   plugins: Plugin[];
// };
// 
// // dpp-ext-lazy
// type LazyMakeStateResult = {
//   plugins: Plugin[];
//   stateLines: string[];
// };
// 
// export class Config extends BaseConfig {
//   override async config(args: ConfigArguments): Promise<ConfigReturn> {
//     const hasNvim = args.denops.meta.host === "nvim";
// 
//     // setting inline_vimrcs
//     const inlineVimrcs = ["$VIM_DIR/settings.vim"];
// 
//     args.contextBuilder.setGlobal({
//       inlineVimrcs,
//       extParams: {
//         installer: {
//           checkDiff: true,
//         },
//       },
//       protocols: ["git"],
//       protocolParams: {
//         git: {
//           enablePartialClone: true,
//         },
//       },
//     });
// 
//     const [context, options] = await args.contextBuilder.get(args.denops);
// 
//     // toml plugins
//     const tomls: Toml[] = [];
//     // non-lazy
//     for (
//       const toml of [
//         "$VIM_TOMLS/dein.toml",
//         "$VIM_TOMLS/ddc.toml",
//         "$VIM_TOMLS/ddu.toml",
//       ]
//     ) {
//       tomls.push(
//         await args.dpp.extAction(
//           args.denops,
//           context,
//           options,
//           "toml",
//           "load",
//           {
//             path: toml,
//             options: {
//               lazy: false,
//             },
//           },
//         ) as Toml,
//       );
//     }
//     // lazy
//     for (
//       const toml of [
//         "$VIM_TOMLS/dein_lazy.toml",
//         hasNvim ? "$VIM_TOMLS/nvim.toml" : "$VIM_TOMLS/vim.toml",
//       ]
//     ) {
//       tomls.push(
//         await args.dpp.extAction(
//           args.denops,
//           context,
//           options,
//           "toml",
//           "load",
//           {
//             path: toml,
//             options: {
//               lazy: true,
//             },
//           },
//         ) as Toml,
//       );
//     }
// 
//     // merge result
//     const recordPlugins: Record<string, Plugin> = {};
//     const ftplugins: Record<string, string> = {};
//     const hooksFiles: string[] = [];
//     for (const toml of tomls) {
//       for (const plugin of toml.plugins) {
//         recordPlugins[plugin.name] = plugin;
//       }
// 
//       if (toml.ftplugins) {
//         for (const filetype of Object.keys(toml.ftplugins)) {
//           if (!ftplugins[filetype]) {
//             ftplugins[filetype] = "";
//           }
//           // ftplugins[filetype] is not undefined
//           ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
//         }
//       }
// 
//       if (toml.hooks_file) {
//         hooksFiles.push(toml.hooks_file);
//       }
//     }
// 
//     const lazyResult = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       "lazy",
//       "makeState",
//       {
//         plugins: Object.values(recordPlugins),
//       },
//     ) as LazyMakeStateResult;
// 
//     // $VIM_DIR/init.vim
//     // $VIM_DIR/settings.vim
//     // $VIM_TOMLS/*,
//     // $VIM_HOOKS/*,
//     const checkFiles: string[] = [];
//     checkFiles.push(
//       ...await fn.globpath(
//         args.denops,
//         "$VIM_DIR",
//         "*.vim",
//         1,
//         1,
//       ) as unknown as string[],
//     );
//     checkFiles.push(
//       ...await fn.globpath(
//         args.denops,
//         "$VIM_TOMLS",
//         "*",
//         1,
//         1,
//       ) as unknown as string[],
//     );
//     checkFiles.push(
//       ...await fn.globpath(
//         args.denops,
//         "$VIM_HOOKS",
//         "*",
//         1,
//         1,
//       ) as unknown as string[],
//     );
// 
//     return {
//       checkFiles,
//       ftplugins,
//       hooksFiles,
//       plugins: lazyResult.plugins,
//       stateLines: lazyResult.stateLines,
//     };
//   }
// }

// ================================================================================================
// import {
//   BaseConfig,
//   ConfigReturn,
//   ContextBuilder,
//   Dpp,
//   Plugin,
// } from "https://deno.land/x/dpp_vim@v0.1.0/types.ts";
// import { Denops, fn } from "https://deno.land/x/dpp_vim@v0.1.0/deps.ts";
// import { expandGlob } from "https://deno.land/std@0.221.0/fs/expand_glob.ts";
// 
// type Toml = {
//   hooks_file?: string;
//   ftplugins?: Record<string, string>;
//   plugins?: Plugin[]
// };
// 
// type LazyMakeStateResult = {
//   plugins: Plugin[];
//   stateLines: string[];
// };
// 
// export class Config extends BaseConfig {
//   override async config(args: {
//     denops: Denops;
//     contextBuilder: ContextBuilder;
//     basePath: string;
//     dpp: Dpp;
//   }): Promise<ConfigReturn> {
// 
// 
//     const [context, options] = await args.contextBuilder.get(args.denops);
// 
//     const tomlPromises = [
//       { path: "~/dotfiles/vim/rc/dein.toml", lazy: false },
//       { path: "~/dotfiles/vim/rc/dein_lsp.toml", lazy: false },
//       { path: "~/dotfiles/vim/rc/dein_treesitter.toml", lazy: false },
//       { path: "~/dotfiles/vim/rc/dein_lazy.toml", lazy: true },
//       { path: "~/dotfiles/vim/rc/dein_lazy_ddc.toml", lazy: true },
//     ].map((tomlFile) =>
//       args.dpp.extAction(
//         args.denops,
//         context,
//         options,
//         'toml',
//         'load',
//         {
//           path: tomlFile.path,
//           options: {
//             lazy: tomlFile.lazy,
//           },
//         },
//       ) as Promise<Toml | undefined>
//     );
// 
//     const tomls: (Toml | undefined)[] = await Promise.all(tomlPromises);
// 
//     const recordPlugins: Record<string, Plugin> = {};
//     const ftplugins: Record<string, string> = {};
//     const hooksFiles: string[] = [];
// 
//     for (const toml of tomls) {
//       if (!toml) {
//         continue;
//       }
// 
//       for (const plugin of toml.plugins ?? []) {
//         recordPlugins[plugin.name] = plugin;
//       }
// 
//       if (toml.ftplugins) {
//         for (const filetype of Object.keys(toml.ftplugins)) {
//           if (ftplugins[filetype]) {
//             ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
//           } else {
//             ftplugins[filetype] = toml.ftplugins[filetype];
//           }
//         }
//       }
// 
//       if (toml.hooks_file) {
//         hooksFiles.push(toml.hooks_file);
//       }
//     }
// 
//     const lazyResult = await args.dpp.extAction(
//       args.denops,
//       context,
//       options,
//       'lazy',
//       'make_state',
//       {
//         plugins: Object.values(recordPlugins),
//       },
//     ) as LazyMakeStateResult | undefined;
// 
//     return {
//       ftplugins,
//       hooksFiles,
//       plugins: lazyResult?.plugins ?? [],
//       stateLines: lazyResult?.stateLines ?? [],
//     }
//   }
// }

