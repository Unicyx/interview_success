import { promptAction, router } from '@kit.ArkUI'
import { auth } from './Auth'
import { http } from './Http'


interface ClockRes {
  clockinNumbers: number
}

export const requestClockIn = async () => {
  const user = auth.getUser()
  if (user.token) {
    if (user.clockinNumbers === 0) {
      const res = await http.request<ClockRes>({ url: 'clockin', method: 'post' })
      user.clockinNumbers = res.clockinNumbers
      auth.setUser(user)
      promptAction.showToast({ message: '打卡成功' })
    }
    router.pushUrl({ url: 'pages/ClockInPage' })
  } else {
    router.pushUrl({ url: 'pages/LoginPage' })
  }
}

export * from './Logger'
export * from './FullScreen'
export * from './StatusBar'
export * from './Http'
export * from './Auth'
export * from './Tracking'
export * from './History'
export * from './Permission'
export * from './AudioDB'
export * from './Theme'


const day = 60 * 60 * 24
const hour = 60 * 60
const min = 60



export const formatTime = (second: number = 0) => {
  if (second > day) {
    return (second / day).toFixed(1) + '天'
  } else if (second > hour) {
    return (second / hour).toFixed(1) + '小时'
  } else {
    return (second / min).toFixed(0) + '分钟'
  }
}

export const calcPercentage = (done: number, total: number) => {
  return Math.round(done / total * 100) + '%'
}