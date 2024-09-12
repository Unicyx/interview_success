import { auth, http, logger, UserStoreKey } from '../commons/utils'
import { User } from '../models'
import { HcLoadingDialog, HcNavBar } from '../commons/components'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'
import { FormData } from '@ohos/axios'
import { image } from '@kit.ImageKit'

@Entry
@Component
struct ProfilePage {
  @StorageProp(UserStoreKey) user: User = {} as User
  dialog: CustomDialogController = new CustomDialogController({
    builder: HcLoadingDialog({ message: '更新中...' }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  build() {
    Column() {
      HcNavBar({ title: '编辑资料', showRightIcon: false })
      List() {
        ListItem() {
          Row() {
            Text('头像')
            Image(this.user.avatar || $r('app.media.ic_mine_avatar'))
              .alt($r('app.media.ic_mine_avatar'))
              .width(40)
              .aspectRatio(1)
              .borderRadius(20)
              .border({ width: 0.5, color: $r('app.color.common_gray_border') })
              .onClick(() => {
                this.updateAvatar()
              })
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.SpaceBetween)
        }

        ListItem() {
          Row() {
            Text('昵称')
            TextInput({ text: this.user.nickName })
              .fontColor($r('app.color.common_gray_03'))
              .textAlign(TextAlign.End)
              .layoutWeight(1)
              .padding(0)
              .height(60)
              .backgroundColor($r('app.color.white'))
              .borderRadius(0)
              .onChange((value) =>
                this.user.nickName = value
              )
              .onSubmit(() => {
                this.updateNickName()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 35,
        right: 35,
        top: 15,
        bottom: 15
      })
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_bg') })
    }
  }
  async updateNickName() {
    await http.request<User>({
      url: 'userInfo/profile',
      method: 'post',
      data: {
        nickName: this.user.nickName
      } as User
    })
    promptAction.showToast({ message: '更新昵称成功' })
    auth.setUser(this.user)
  }
  async updateAvatar() {
    // 1. 选择相册照片
    // 选择照片配置
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    photoSelectOptions.maxSelectNumber = 1
    // 选择照片对象
    const photoPicker = new photoAccessHelper.PhotoViewPicker()
    const photoResult = await photoPicker.select(photoSelectOptions)
    const uri = photoResult.photoUris[0]
    this.dialog.open()
    // // 2. 拷贝选择的图片到应用沙箱
    // const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
    // const filePath = getContext(this).cacheDir + '/' + file.name
    // fileIo.copyFileSync(file.fd, filePath)
    // fileIo.closeSync(file.fd)
    // const formData = new FormData()
    // formData.append('file', `internal://cache/${file.name}`)


    // 2. 拷贝选择的图片到应用沙箱，并压缩
    const originFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
    // const filePath = getContext(this).cacheDir + '/' + file.name
    // fileIo.copyFileSync(file.fd, filePath)
    // fileIo.closeSync(file.fd)
    // 压缩
    const imageSource = image.createImageSource(originFile.fd)
    const imagePacker = image.createImagePacker()
    const arrayBuffer = await imagePacker.packing(imageSource, { format: "image/jpeg", quality: 70})
    const newFilePath = getContext(this).cacheDir + '/' + Date.now() + '.jpg'
    const newFile = fileIo.openSync(newFilePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    fileIo.writeSync(newFile.fd, arrayBuffer)
    logger.debug('size', fileIo.statSync(newFile.fd).size.toString())
    fileIo.closeSync(newFile.fd)

    const formData = new FormData()
    formData.append('file', `internal://cache/${newFile.name}`)

    // 3. 提交数据
    const url = await http.request<string>({
      url: 'userInfo/avatar',
      method: 'post',
      data: formData,
      headers: { 'Content-Type': 'multipart/form-data' },
      context: getContext(this)
    })
    const user = await http.request<User>({ url: 'userInfo' })
    this.user.avatar = user.avatar
    auth.setUser(this.user)
    promptAction.showToast({ message: '更新头像成功' })
    this.dialog.close()
  }
}