{ pkgs, nixvim, ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = false;

    extraConfigLua = ''
      -- VS Code 集成支持
      if vim.g.vscode then
        -- VS Code 特定配置
        print("Hi, I'm nixvim in VS Code!")
      else
        -- 普通 Neovim 配置
        print("Hi, I'm nixvim!")
      end
    '';

    plugins = {
      # 基础编辑功能
      comment.enable = true;
      treesitter.enable = true;
      treesitter-context.enable = true;
      treesitter-refactor.enable = true;
      rainbow-delimiters.enable = true;
      vim-surround.enable = true;
      leap.enable = true;
      indent-blankline.enable = true;
      gitsigns.enable = true;
      
      # 文件管理
      neo-tree.enable = true;
      oil.enable = true;
      
      # 工具和增强
      bufferline.enable = true;
      diffview.enable = true;
      easyescape.enable = true;
      fugitive.enable = true;
      harpoon.enable = true;
      nvim-bqf.enable = true;
      colorizer.enable = true;
      markdown-preview.enable = true;
      lightline.enable = true;
      nix.enable = true;
      neorg.enable = true;
      web-devicons.enable = true;
    };

    # LSP 配置
    plugins.lsp.enable = true;
    plugins.lsp.servers.pyright.enable = true;
    plugins.lsp.servers.nixd.enable = true;

    # 额外插件 - VS Code 集成相关
    extraPlugins = with pkgs.vimPlugins; [
      vim-nix
      # LazyVim VS Code 集成所需的插件
      dial-nvim
      flit-nvim
      leap-nvim
      mini-ai
      mini-comment
      mini-move
      mini-pairs
      mini-surround
      nvim-treesitter
      nvim-treesitter-textobjects
      nvim-ts-context-commentstring
      vim-repeat
      yanky-nvim
    ];

  };

}
