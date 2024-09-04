import { TimeItem } from '../../models'
import { http } from './Http'
import { preferences } from '@kit.ArkData'
import { JSON } from '@kit.ArkTS'

class Tracking {
  store: preferences.Preferences | null = null
  dataKey: string = 'time-list'

  getStore() {
    if (!this.store) {
      const context = AppStorage.get<Context>('context')
      const dataPreferences = preferences.getPreferencesSync(context, { name: 'tracking-store' })
      this.store = dataPreferences
    }
    return this.store
  }

  async record(startTime: number, endTime: number, questionId: string) {
    const json = this.getStore().getSync(this.dataKey, '[]')
    const list = JSON.parse(json as string) as TimeItem[]
    list.push({ startTime, endTime, questionId })
    this.getStore().putSync(this.dataKey, JSON.stringify(list))
    await this.getStore().flush()
  }

  async report(force: boolean = false) {
    const json = this.getStore().getSync(this.dataKey, '[]')
    const list = JSON.parse(json as string) as TimeItem[]
    if (list.length >= 5 || (force && list.length )) {
      await http.request<null>({ url: 'time/tracking', method: 'post', data: { timeList: list } })
      this.getStore().deleteSync(this.dataKey)
      await this.getStore().flush()
    }
  }
}
/**
 * * 定时上报: 设置一个定时器，定期（如每 5 分钟）将积累的数据发送到服务器。
 * * 使用本地存储: 将上报数据存储在设备的持久化存储中，这样即使应用退出，数据依然保留。
 * * 应用启动时上报: 在应用启动或用户登录成功后，将持久化存储中的数据上报到服务器。
 * */
export const tracking = new Tracking()