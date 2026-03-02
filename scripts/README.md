# 缓存配置系统

## 简介

这个缓存配置系统用于管理和共享各种工具的缓存目录，特别是针对Python开发和大模型使用场景。通过将缓存目录映射到共享存储，可以在多个系统间共享缓存，节省存储空间并保持环境一致性。

## 目录结构

```
scripts/
├── cache_config.sh       # 主缓存配置脚本
├── update_cache_config.sh  # 手动更新缓存配置的辅助脚本
└── README.md            # 本说明文件
```

## 主要功能

1. **统一管理缓存路径** - 将所有缓存目录集中到共享存储
2. **自动创建符号链接** - 为不支持XDG标准的工具创建符号链接
3. **提供便捷命令** - 如 `cache_paths` 和 `clean_cache`
4. **跨系统共享** - 在多个系统间共享缓存，避免重复下载

## 配置说明

### 1. 共享存储路径

默认共享存储路径为：`/mnt/wsl/persistent`

如需修改，请编辑 `scripts/cache_config.sh` 文件中的 `SHARED_BASE` 变量。

### 2. 缓存目录结构

```
/mnt/wsl/persistent/
├── cache/              # XDG_CACHE_HOME
│   ├── huggingface/    # HuggingFace模型缓存
│   ├── pip/            # Pip包缓存
│   ├── uv/             # UV包管理器缓存
│   ├── poetry/         # Poetry缓存
│   ├── torch/          # PyTorch缓存
│   └── ...             # 其他缓存目录
├── data/               # XDG_DATA_HOME
│   ├── atuin/          # Atuin历史命令
│   ├── zoxide/         # Zoxide跳转记录
│   └── ...             # 其他数据目录
├── state/              # XDG_STATE_HOME
│   └── nix/            # Nix状态数据
└── conda/              # Conda环境
    └── envs/           # Conda环境目录
```

## 使用方法

### 1. 初始化配置

运行 `home-manager switch` 会自动部署和执行缓存配置：

```bash
home-manager switch
```

### 2. 查看缓存路径

在任何shell中运行：

```bash
cache_paths
```

### 3. 清理缓存

```bash
# 清理所有缓存
clean_cache all

# 清理HuggingFace缓存
clean_cache hf

# 清理Pip缓存
clean_cache pip

# 清理PyTorch缓存
clean_cache torch
```

### 4. 手动更新配置

```bash
~/.config/home-manager/scripts/update_cache_config.sh
```

## 环境变量

脚本会设置以下环境变量：

- `XDG_CACHE_HOME` - 缓存目录
- `XDG_DATA_HOME` - 数据目录
- `XDG_STATE_HOME` - 状态目录
- `HF_HOME` - HuggingFace缓存
- `TORCH_HOME` - PyTorch缓存
- `PIP_CACHE_DIR` - Pip缓存
- `CONDA_ENVS_PATH` - Conda环境目录
- 以及其他工具的缓存路径

## 注意事项

1. **权限问题** - 确保共享目录对所有用户有正确的读写权限
2. **性能考虑** - 共享存储的I/O性能会影响工具启动速度
3. **备份策略** - 定期备份共享目录中的重要缓存
4. **兼容性** - 某些工具可能不支持自定义缓存路径

## 故障排除

### 符号链接创建失败

如果符号链接创建失败，请检查：
- 共享目录是否存在且可写
- 目标路径是否正确
- 权限是否足够

### 缓存路径不生效

如果缓存路径不生效，请检查：
- 脚本是否被正确加载
- 环境变量是否被正确设置
- 工具是否支持自定义缓存路径

### 手动测试

```bash
# 测试脚本执行
bash ~/.cache_config.sh

# 检查环境变量
echo $HF_HOME
echo $TORCH_HOME

# 检查符号链接
ls -la ~/.cache/
```

## 扩展

如需添加新的缓存目录：

1. 在 `scripts/cache_config.sh` 中添加相应的环境变量
2. 在 `mkdir` 命令中添加新的目录
3. 添加相应的符号链接创建命令
4. 在 `cache_paths` 函数中添加新的路径显示

## 版本历史

- v1.0 - 初始版本，支持基本缓存目录管理
- v1.1 - 添加PyTorch缓存支持
- v1.2 - 优化符号链接创建逻辑