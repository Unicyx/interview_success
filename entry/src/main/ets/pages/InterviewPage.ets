import { auth } from '../commons/utils/Auth'

@Component
export struct InterviewPage {
  build() {
    Button('Interview')
      .onClick(() => {
        auth.checkAuth({
          url: 'pages/AudioPage'
        })
      })
  }
}