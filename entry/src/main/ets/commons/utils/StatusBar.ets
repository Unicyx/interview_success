import { window } from '@kit.ArkUI'
import { logger } from './Logger'

class StatusBar {
  async setDarkBar() {
    await this.setBar({ statusBarContentColor: '#000000' })
  }

  async setLightBar() {
    await this.setBar({ statusBarContentColor: '#FFFFFF' })
  }

  async setBar(config: window.SystemBarProperties) {
    try {
      const context = AppStorage.get<Context>('context')
      if (context) {
        const win = await window.getLastWindow(context)
        await win.setWindowSystemBarProperties(config)
      }
    } catch (e) {
      logger.error('StatusBar setBar', JSON.stringify(e))
    }
  }
}

export const statusBar = new StatusBar()