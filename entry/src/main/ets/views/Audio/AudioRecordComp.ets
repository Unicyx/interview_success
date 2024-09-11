import { media } from '@kit.MediaKit'
import { fileIo } from '@kit.CoreFileKit'
import { auth, InterviewAudioItem, logger } from '../../commons/utils'
import { AudioBoComp } from './AudioBoComp'


@Component
export struct AudioRecordComp {
  @StorageProp('bottomHeight') bottomHeight: number = 0
  startTime: number = 0
  avRecorder?: media.AVRecorder
  fd?: number
  filePath?: string

  timer?: number
  @State maxAmplitude: number = 0

  @State recording: boolean = false
  onRecordEnd: (item: InterviewAudioItem) => void = () => {}

  async startRecord() {
    this.startTime = Date.now();
    // 1. 准备一个文件接收录音
    const ctx = getContext(this)
    const filePath = ctx.filesDir + '/' + Date.now() + '.m4a'
    this.filePath = filePath
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    this.fd = file.fd
    // 2. 准备路由配置对象
    const config: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      profile: {
        audioBitrate: 100000, // 音频比特率
        audioChannels: 1, // 音频声道数
        audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前只支持aac
        audioSampleRate: 48000, // 音频采样率
        fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前只支持m4a
      },
      url: `fd://${file.fd}`
    }
    // 3. 开始录制
    const avRecorder = await media.createAVRecorder()
    await avRecorder.prepare(config)
    await avRecorder.start()
    this.avRecorder = avRecorder
    // startRecord 4. 每100ms获取一下声音振幅
    this.timer = setInterval(async () => {
      this.maxAmplitude = await avRecorder.getAudioCapturerMaxAmplitude()
      logger.debug('startRecord', this.maxAmplitude.toString())
    }, 100)
  }

  async stopRecord() {
    if (this.avRecorder) {
      clearInterval(this.timer)
      await this.avRecorder.stop()
      await this.avRecorder.release()
      fileIo.closeSync(this.fd)
      this.maxAmplitude = 0
    }
  }

  formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');

    return `${year}年${month}月${day}日_${hours}时${minutes}分${seconds}秒`
  }

  build() {
    Column() {
      AudioBoComp({ maxAmplitude: this.maxAmplitude })
      Row() {
        Image($r('sys.media.ohos_ic_public_voice'))
          .width(24)
          .aspectRatio(1)
          .fillColor(this.recording ? Color.Black : $r('app.color.white'))
          .onClick(async () => {
            if (this.recording) {
              await this.stopRecord()
              this.recording = false

              const stat = fileIo.statSync(this.filePath)
              this.onRecordEnd({
                id: null,
                name: this.formatDate(new Date()),
                path  : this.filePath || '',
                duration:  Date.now() - this.startTime,
                size: stat.size,
                user_id: auth.getUser().id,
                create_time: Date.now()
              })

            } else {
              await this.startRecord()
              this.recording = true
            }
          })
      }
      .justifyContent(FlexAlign.Center)
      .height(50)
      .width(50)
      .borderRadius(25)
      .margin({ top: 20 })
      .backgroundColor(this.recording ? Color.Red : $r('app.color.black'))
    }
    .width('100%')
    .height(240)
    .backgroundColor($r('app.color.common_gray_bg'))
    .padding({ bottom: this.bottomHeight, left: 80, right: 80, top: 20 })
  }
}
