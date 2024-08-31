import { HcLoadingDialog, HcNavBar, HcTag } from '../commons/components'
import { QuestionDetail, QuestionPageParams } from '../models'
import { router } from '@kit.ArkUI'
import { http } from '../commons/utils'
import { webview } from '@kit.ArkWeb'


@Entry
@Component
struct QuestionPage {
  @StorageProp('bottomHeight') bottomHeight: number = 0
  @State item: QuestionDetail = {} as QuestionDetail

  controller = new webview.WebviewController()

  async aboutToAppear() {
    const params = router.getParams() as QuestionPageParams
    if (params) {
      this.item = params.item as QuestionDetail
      this.item = await this.getQuestionDetail(this.item.id)
      this.controller.loadUrl($rawfile('question.html'))
    }
  }
  dialog = new CustomDialogController({
    builder: HcLoadingDialog(),
    customStyle: true,
    alignment: DialogAlignment.Center
  })
  async getQuestionDetail (id: string) {
    this.dialog.open()
    const res = await http.request<QuestionDetail>({ url: `question/${id}` })
    this.dialog.close()
    return res
  }
  @Builder
  TitleBuilder(text: string) {
    Row() {
      Text()
        .width(2)
        .height(12)
        .backgroundColor($r('app.color.black'))
        .margin({ right: 13 })
      Text(text)
        .fontWeight(700)
    }
    .width('100%')
    .padding({ top: 10 })
    .height(32)
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: '点赞' })
      MenuItem({ content: '收藏' })
      MenuItem({ content: '点我反馈' })
      MenuItem({ content: '试题分享' })
    }
    .width(108)
  }

  build() {
    Column() {
      HcNavBar({ title: '试题详情', showRightIcon: false })
      // 题目
      this.TitleBuilder('题目：')
      Text('ArkUI的容器组件有哪些？')
        .width('100%')
        .padding(16)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 12 }) {
        HcTag({ text: 'HarmonyOS' })
        HcTag({ text: 'ArkTS', color: '#ff6600' })
        Blank()
        Image($r("app.media.ic_home_more"))
          .width(20)
          .aspectRatio(1)
          .bindMenu(this.MenuBuilder())
      }
      .width('100%')
      .padding({ bottom: 16, left: 16, right: 16 })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))
      // 内容
      this.TitleBuilder('答案：')
      Web({ src: $rawfile('question.html'), controller: this.controller })
        .width('100%')
        .layoutWeight(1)
        .onPageEnd(() => {
          if (this.item.answer) {
            this.controller.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)
          }
        })

      Row({ space: 80 }) {
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
          Text(' 上一题')
            .fontColor($r('app.color.common_gray_01'))
        }

        Row() {
          Text('下一题 ')
            .fontColor($r('app.color.common_gray_03'))
          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_03'))
        }
      }
      .height(44)
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: this.bottomHeight })
  }
}