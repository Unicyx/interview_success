import { HcClockIn, HcSearchBox } from '../commons/components'
import { HomeCategory } from '../views/Home/HomeCategory'

@Component
export struct HomePage {
  @StorageProp('topHeight') topHeight: number = 0
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
  build() {
    Column() {
      Row({ space: 16 }) {
        Image($r('app.media.ic_home_scan'))
          .width(24)
          .aspectRatio(1)
        HcSearchBox({ layoutWeightValue: 1})
        HcClockIn()
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
}