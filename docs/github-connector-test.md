# GitHub 连接器测试文档

这是一次由 ChatGPT 通过 OpenAI 关联的 GitHub 连接器写入 `toophy/test-a` 仓库的测试文档。

## 测试目的

- 验证 ChatGPT 能访问该仓库。
- 验证 ChatGPT 具备写入/提交权限。
- 为后续测试 Issue、PR、分支、文件修改、Actions 等操作提供一个初始文件。
- 验证分支写入、文件更新、PR diff、Issue、评论等操作。

## 记录

- 仓库：`toophy/test-a`
- 写入方式：GitHub 连接器 contents API
- 说明：这不是当前容器里用 `git push` 直接推送，而是通过已授权 GitHub API 创建提交，效果等价于向仓库提交文件。

## Smoke Test

- 分支：`chatgpt/connector-smoke-test`
- 操作：更新已有 Markdown 文件
- 状态：已由 ChatGPT 连接器写入
