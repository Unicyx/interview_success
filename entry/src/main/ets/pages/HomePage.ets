import { HcClockIn, HcSearchBox } from '../commons/components'
import { auth, http, requestClockIn, tracking, UserStoreKey } from '../commons/utils'
import { HomeCategory } from '../views/Home/HomeCategory'
import { scanBarcode } from '@kit.ScanKit'
import { promptAction, router } from '@kit.ArkUI'
import { QuestionDetail, User } from '../models'

@Component
export struct HomePage {
  @StorageProp('topHeight') topHeight: number = 0
  @StorageProp(UserStoreKey) user: User = {} as User
  @Builder
  SwiperItemBuilder(src: ResourceStr) {
    Row() {
      Image(src)
        .width('100%')
        .aspectRatio(2.65)
        .objectFit(ImageFit.Fill)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
  aboutToAppear(): void {
    tracking.report(true)
  }
  build() {
    Column() {
      Row({ space: 16 }) {
        Image($r('app.media.ic_home_scan'))
          .width(24)
          .aspectRatio(1)
          .onClick(() => {
            auth.checkAuth(() => {
              this.scanQuestionCode()
            })
          })
        HcSearchBox({ layoutWeightValue: 1 })
        HcClockIn({ clockInCount: this.user.clockinNumbers })
          .onClick(() => {
            requestClockIn()
          })
      }
      .padding({ left: 16, right: 16 })
      .height(64)
      .width('100%')
      Swiper() {
        ForEach([$r('app.media.banner_ai'), $r('app.media.banner_pj'), $r('app.media.banner_qa')],
          (item: ResourceStr) => {
            this.SwiperItemBuilder(item)
          })
      }
      .margin({ bottom: 16 })
      .autoPlay(true)
      .indicator(DotIndicator.dot()
        .bottom(4)
        .itemHeight(4)
        .selectedItemHeight(4)
        .selectedColor($r('app.color.white')))
      // 试题Tabs
      Column(){
        HomeCategory()
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.white'))
    }
    .padding({ top: this.topHeight })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_gray_bg'))
    .backgroundImageSize(ImageSize.Contain)

  }

  async scanQuestionCode() {
    if (canIUse('SystemCapability.Multimedia.Scan.ScanBarcode')) {
      //调用上下文，可以确保为当前实例，而不是出现别的情况，比如切屏后的变化
      const result = await scanBarcode.startScanForResult(getContext(this))
      if (result.originalValue) {
        try {
          const item = await http.request<QuestionDetail>({ url: `question/${result.originalValue}` })
          router.pushUrl({
            url: 'pages/QuestionPage',
            params: {
              item,
              list: [item]
            }
          })
        } catch (e) {
          promptAction.showToast({ message: '没有找到试题' })
        }
      }
    }
  }
}