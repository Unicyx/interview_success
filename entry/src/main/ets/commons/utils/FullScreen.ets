import { window } from '@kit.ArkUI';
import { logger } from './logger';

class FullScreen {
  async enable() {
    try {
      const context = AppStorage.get<Context>('context')
      if (context) {
        const win = await window.getLastWindow(context)
        await win.setWindowLayoutFullScreen(true)
        const topArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        AppStorage.setOrCreate('topHeight', px2vp(topArea.topRect.height))
        const bottomArea =  win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        AppStorage.setOrCreate('bottomHeight', px2vp(bottomArea.bottomRect.height))
      }
    } catch (e) {
      logger.error('FullScreen enable', JSON.stringify(e))
    }
  }

  async disable() {
    try {
      const context = AppStorage.get<Context>('context')
      if (context) {
        const win = await window.getLastWindow(context)
        await win.setWindowLayoutFullScreen(false)
        AppStorage.setOrCreate('topHeight', 0)
        AppStorage.setOrCreate('bottomHeight', 0)
      }
    } catch (e) {
      logger.error('FullScreen disable', JSON.stringify(e))
    }
  }
}

export const fullScreen = new FullScreen()