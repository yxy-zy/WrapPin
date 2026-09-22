# WrapPin 1.0.8（Build 15）

## 中文

本版在设置中增加“隧道应用”选择，可指定 LocalDevVPN 或 Shadowrocket。当 WrapPin 找不到已配对 iPhone 的设备连接时，会打开所选应用，让使用者检查并开启兼容隧道。Wi-Fi 下如果本次连接已经可达，不会仅因开始模拟定位而重复跳转。

LocalDevVPN 在蜂窝网络下继续使用原有的开启隧道并返回流程。Shadowrocket 仅能被打开，WrapPin 无法读取其 VPN 开关，也不能保证普通代理配置具有所需的本机设备连接；蜂窝网络下连接失败时，页面会建议改用 Wi-Fi。诊断页和连接失败提示也改为准确描述“设备通道可达性”。本版不改变位置坐标精度或漂移处理。

### 下载与验证

- 文件：`WrapPin-1.0.8-build15.ipa`
- 最低系统：iOS 27.0；架构：arm64；Bundle ID：`com.suversal.wrappin`
- 签名：未签名，需由 SideStore 或自己的开发者身份签名安装。
- SHA-256：`c05c943b0274879286363e504c95c23a8cba0f4cf74c228a61a9e7243ad6e218`
- 已通过本地化、原生错误分类、后台会话生命周期、隧道跳转策略、路线恢复检查，以及 Release Archive、IPA 结构、版本、架构、隐私清单和许可证资源校验。
- 用户反馈前一测试包 Build 14“看上去可以”；最终 Build 15 尚未单独完成真机安装和 Wi-Fi/蜂窝 × 两款隧道应用的完整验收。匿名使用统计的上传配置在此构建中留空，因此即使打开开关也不会发送事件。

### 当前边界

LocalDevVPN 在蜂窝网络下每次新建会话仍会按原流程打开一次。Shadowrocket 在蜂窝网络下可能无法提供本机配对通道；建议使用 Wi-Fi，或选择 LocalDevVPN。是否已经开启某个第三方 VPN 无法直接从 WrapPin 读取，只有配对设备的实际可达性可以验证。

## English

WrapPin 1.0.8 adds a Settings choice for the tunnel app opened when the paired iPhone is unreachable: LocalDevVPN or Shadowrocket. On Wi-Fi, a reachable device connection avoids an unnecessary handoff. LocalDevVPN keeps its existing cellular connect-and-return flow; Shadowrocket opens without controlling or reading its VPN switch. If Shadowrocket cannot expose the device connection on cellular, use Wi-Fi or LocalDevVPN. This release does not change location accuracy.

The unsigned `WrapPin-1.0.8-build15.ipa` requires iOS 27.0 or later and has SHA-256 `c05c943b0274879286363e504c95c23a8cba0f4cf74c228a61a9e7243ad6e218`. Archive, package, localization, native-error, background-session, tunnel-policy and route-recovery checks passed. The user reported that the preceding Build 14 candidate looked okay; the final Build 15 package has not had a separate physical-device matrix test. Telemetry ingestion identifiers are blank in this build, so optional anonymous event delivery is inactive.
