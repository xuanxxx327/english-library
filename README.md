# English Library

私人英语学习资料库，面向手机。部署到原 GitHub Pages 地址，不更换 origin。

## 使用
1. 在原手机浏览器导出 JSON 备份，并确认下载成功。
2. 邮箱注册、确认邮箱，再登录。邮件需 Supabase 正确配置 SMTP 与 Auth Site URL/Redirect URL：https://xuanxxx327.github.io/english-library/ 。这些 Auth 设置未通过本次工具核实。
3. 在“本机原有资料”点击“上传当前资料”。图片、音频先写入私有桶，卡片随后写入 learning_cards。
4. 换设备登录后点击“从云端恢复”。恢复写入账号独立 IndexedDB，不覆盖原本机库。

同步是手动、仅追加版本：相同内容按 SHA-256 去重，修改另存版本，删除只进入本机回收站，云端不传播删除。首次同步下载备份后仍需用户确认文件实际保存。

## 数据保护
- 原库 english-library-v1 / cards 保留，不升级、不清空；合并导入完整校验后原子添加。
- 账号缓存 english-library-account-<user UUID>；退出隐藏账号缓存。缓存并非加密保险箱，仅应在自己的设备使用。
- 私有桶 english-library-private，路径 <auth.uid>/<content hash>/image 或 audio。
- 前端仅 publishable key；RLS 校验 user_id 与 auth.uid，Storage RLS 校验首层用户目录。
- 下载分页，全部媒体验证通过后单一 IndexedDB 事务写入，失败保持已有资料。
- 浏览器多标签页使用 Web Locks 串行化写操作；服务端唯一索引处理跨设备重复上传。
- 数据内容用 text/HTML escaping 渲染；从云端读取不使用永久公开 URL。

## 校验
运行 npm install 与 npm test。测试使用 fake-indexeddb 与模拟 Supabase，覆盖原 9 张卡片保留、媒体往返、重复上传、修改版本、下载失败、账号隔离、路径拒绝、切换中止、导入原子性。
实际数据库 RLS 测试使用事务内临时用户和数据，最后 ROLLBACK，不留下测试卡片。
真实邮箱收信、用户实际登录及安卓原数据首次上传仍需使用者验证。

Supabase JS 2.57.4 固定版本随站点提供，来自官方 npm 包的 UMD 发布文件；不依赖运行时外部 CDN。

