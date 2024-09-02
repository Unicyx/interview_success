import { QuestionItemComp } from './'
import { PageData, QuestionItem, QuestionListParams, QuestionPageParams, SortType } from '../../models'
import { auth, http } from '../../commons/utils'
import { promptAction } from '@kit.ArkUI'

@Component
export struct QuestionListComp {
  @State list: QuestionItem[] = []
  // 控制刷新的状态
  @State isRefreshing: boolean = false
  // 是否加载完成
  @State isFinished: boolean = false
  // 正在加载中...
  @State isLoading: boolean = false
  // 试题ID
  @Prop typeId: number
  @State page: number = 1
  @Prop @Watch('onChangeSort') sort: SortType = SortType.Default
  @Prop activeIndex: number
  @Prop index: number
  @Builder
  LoadMoreBuilder() {
    ListItem() {
      // 加载完成
      if (this.isFinished) {
        Row() {
          Text('没有更多了~')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
      // 没有加载完成且正在加载中
      else if (this.isLoading) {
        Row({ space: 4 }) {
          LoadingProgress()
            .width(20)
          Text('正在加载...')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
    }
    .height(80)
  }

  async onRefresh() {
    this.page = 1
    const res = await this.getQuestionList()
    this.list = res.rows
    this.isRefreshing = false
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.isFinished = false
      this.page++
    }
    promptAction.showToast({ message: '更新成功' })
  }
  // 加载逻辑
  async onLoad() {
    const res = await this.getQuestionList()
    this.list.push(...res.rows)
    this.isLoading = false
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.page++
    }
  }
  build() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List() {
        ForEach(this.list, (item: QuestionItem, index) => {
          ListItem() {
            QuestionItemComp({ item: item })
              .onClick(() => {
                auth.checkAuth({
                  url: 'pages/QuestionPage',
                  params: {
                    item,
                    list: this.list
                  } as QuestionPageParams
                })
              })
          }
        })
        this.LoadMoreBuilder()
      }
      .onReachEnd(() => {
        if (this.isLoading || this.isFinished || this.isRefreshing ) {
          return
        }
        this.isLoading = true
        this.onLoad()
      })
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_border'),
        startMargin: 16,
        endMargin: 16
      })
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
    // Refresh 绑定事件
    .onRefreshing(() => {
      this.onRefresh()
    })
  }
  getQuestionList(): Promise<PageData<QuestionItem>> {
    return http.request<PageData<QuestionItem>>({
      url: 'question/list',
      params: {
        type: this.typeId,
        questionBankType: 10,
        sort: this.sort,
        page: this.page,
        pageSize: 10
      } as QuestionListParams
    })
  }
  onChangeSort() {
    //等待ui更新同步到所有位置后，再进行刷新，确保安全和用户体验
    setTimeout(() => {
      if (this.activeIndex === this.index) {
        this.isRefreshing = true
      }
    })
  }
}