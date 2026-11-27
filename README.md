# carwithin-voge-build

把 VOGE 无极 DS625X 七寸仪表的投屏协议移植进 [CarWithin](https://github.com/xmz28/CarWithin)，并用 GitHub Actions 云端编出**未签名 IPA**，
绕开本地 macOS 12 装不了新版 Xcode 的问题。

- 补丁来源：`7rzjnd7rw5-ops/carbit-probe`（极享 Android 版，实车跑通的那套 PXC + RV 投屏）
- 补丁内容：新增 `VogeConnection.swift`、`InstrumentVideoSession.swift`，改 `CfmotoOutput.swift`、`MotorcycleProfile.swift`（加“无极 DS625X 7 寸”车型）、`project.pbxproj`
- 本仓库只放工作流，**不放整份上游代码**：每次运行现拉上游 + 打补丁，避免跟着上游改动手工同步

## 一、怎么出 IPA

1. 打开仓库 → **Actions** 标签 → 左边选 **Build unsigned IPA (CarWithin + VOGE DS625X)**
2. 右边 **Run workflow** → 分支保持 `main` → 直接点绿色 **Run workflow**（输入项都有默认值，不用改）
3. 等 10～20 分钟，进度变绿后点进这次运行，页面**最底部 Artifacts**：
   - `CarWithin-VOGE-unsigned-ipa.zip` ← 要的就是这个
   - 如果失败，下 `build-log` 看编译错误
4. 解压 zip 得到 `CarWithin-VOGE-unsigned.ipa`

## 二、怎么装进 iPhone

1. 下载 [Sideloadly](https://sideloadly.io)（Mac/Windows 都有），打开
2. iPhone 插线，Sideloadly 顶部识别到设备后，把 `.ipa` 拖进 **IPA** 框
3. **Apple account** 填你的 Apple ID（免费账号即可），点 **Start**
4. 提示输入密码 → 走完；失败就按提示在 appleid.apple.com 生成一个 **App 专用密码** 再填
5. iPhone 上：设置 → 通用 → VPN与设备管理 → 开发者App → 信任你的 Apple ID
6. 打开 App，允许**本地网络**权限（不给这个权限，10922/10921/10920 一个都监听不了）

免费账号签的包 **7 天过期**，到期用 Sideloadly 重装一次即可。

## 三、上机使用

1. iPhone 在系统设置里连仪表广播的 Wi-Fi（确认过仪表是普通 AP 不是 P2P）
2. App → 设置 → 输出选 **无极 DS625X 7 寸（实验）**，IP 留空
3. 仪表停在「手机互联」页面 → 回 App 启动 CarPlay
4. 日志按这个顺序走通就是成功：`已监听 …` → `★ 仪表回连 TCP10922` → `采集配置` → `仪表要求开流` → `SN 校验通过并跳到投屏页` → `★ 仪表回连 TCP10920` → `第 1 帧 … 已送`

## 四、以后自己魔改怎么再出包

1. 本地改 `~/Downloads/CarWithin` 里的代码
2. 在该目录执行（`make-patch.sh` 也在本仓库里）：

   ```bash
   git add -N App/VogeConnection.swift App/InstrumentVideoSession.swift   # 新增文件首次要加
   git diff -- App TDSCarKit.xcodeproj > voge-port.patch
   ```

3. 把新的 `voge-port.patch` 拖到本仓库网页根目录（GitHub 支持直接拖拽上传，选 Replace 覆盖）
4. 再跑一次 workflow —— 工作流会**优先用仓库里的 `voge-port.patch`**，不用改任何参数

## 五、注意

- 上游 CarWithin 是 **AGPL-3.0**，本仓库的补丁同协议，二次分发请保留协议与署名
- 工作流默认 pin 在 `cffbf58`（2026-11-27，补丁已验证可干净应用）。想跟上游最新，把 `upstream_ref` 填成 `main`，但补丁可能会冲突
- 编出来的 IPA 是**未签名**的，必须自己签，不能直接装
