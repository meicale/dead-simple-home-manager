{ pkgs, nixvim, ... }:
{
  # 移除或注释掉当前有问题的 nixvim 配置
  # programs.nixvim.enable = true;
# TODO: add keys for which key, harpoon, etc.
# TODO: add nerd fonts to this.
  programs.nixvim = {
    enable = true;

    # extraConfigLua = ''
    #   -- Print a little welcome message when nvim is opened!
    #   print("Hi, I'm nixvim!")
    # '';

    # options = {
    #   # number = true;         # Show line numbers
    #   # relativenumber = true; # Show relatimve line numbers
    #   shiftwidth = 2;        # Tab width should be 2
    # };

#     # colorschemes.gruvbox.enable = true;
#     # plugins.alpha.enable = true;
    plugins.bufferline.enable = true;
    plugins.comment.enable = true;
    plugins.diffview.enable = true;
    plugins.easyescape.enable = true;
    plugins.treesitter.enable = true;
    plugins.treesitter-context.enable = true;
    plugins.treesitter-refactor.enable = true;
    plugins.rainbow-delimiters.enable = true;
    plugins.vim-surround.enable = true;
    plugins.web-devicons.enable = true;
    plugins.neorg.enable = true;
    plugins.neo-tree.enable = true;
    plugins.nix.enable = true;
    plugins.fugitive.enable = true;
    plugins.gitsigns.enable = true;
    plugins.harpoon.enable = true;
    plugins.indent-blankline.enable = true;
    plugins.leap.enable = true;
    plugins.nvim-bqf.enable = true;
    plugins.colorizer.enable = true;  # 使用新的插件名称
    plugins.oil.enable = true;
    plugins.markdown-preview.enable = true;
    plugins.lightline.enable = true;


    # plugins.flash.enable = true;
    # plugins.flash.settings.label.after = [0 2];  # 修改后的属性路径
    # keymaps = [
    #   {
    #     mode = "n";
    #     key = "s";
    #     action = "require('flash').jump";
    #     lua = true;
    #   }
    # ];

    # 需要设置相应的安装程序，也就是 lsp 服务器
    # plugins.lsp.enable = true;
    # plugins.lsp.servers.pyright.enable = true;
    # plugins.lsp.servers.nixd.enable = true;

    # # TODO: enable which-key
#     plugins.which-key.enable = true;
#     plugins.wilder.enable = true;
#     extraPlugins = with pkgs.vimPlugins; [
#       vim-nix
#     ];

  };

}
