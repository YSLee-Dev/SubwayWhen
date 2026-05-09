//
//  DetailArrivalView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/27/24.
//

import SwiftUI

struct DetailArrivalView: View {
    @State private var backStationPostion: (CGFloat, Double) = (0, 0)
    @State private var nextStationPostion: (CGFloat, Double) = (0, 1)
    @State private var borderSize = 1.0
    @State private var borderPostion = 0.0
    @State private var nowAnimationPlaying = false
    @State private var trainPostion = 0.0
    @State private var nowAnimationHalfPlaying = false
    @State private var refreshBtnTapAnimation = false
    @State private var defaultStationWidth = 0.0
    @State private var firstArrivalCode: String = "-"
    @State private var isTrainIconShow = false
    
    private let screenWidthSize = UIScreen.main.bounds.width -  40
    
    var arrivalDataList: [TotalRealtimeStationArrival]
    let stationInfo: DetailSendModel
    let backStationName: String
    var nowLoading: Bool
    var nowSeconds: Int?
    let isDisposable: Bool
    let refreshBtnTapped: () -> ()
    var realtimeBtnTapped: (() -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("실시간 현황")
                    .foregroundColor(.gray)
                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .semibold))
                Spacer()
            }
            .padding(.bottom, 15)
            
            MainStyleViewInSUI {
                HStack(alignment: .top, spacing: 30) {
                    VStack(alignment: .leading, spacing: 5) {
                        Circle()
                            .stroke(Color.init(self.stationInfo.lineNumber))
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                        
                        Text(self.stationInfo.stationName)
                            .lineLimit(1)
                            .layoutPriority(1)
                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .bold))
                    }
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    self.defaultStationWidth = geo.size.width
                                }
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Circle()
                            .stroke(Color.init(self.stationInfo.lineNumber))
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                            .offset(x: self.backStationPostion.0)
                            .opacity(self.nowAnimationPlaying ? 1 : self.backStationPostion.1)
                        
                        if self.backStationPostion.1 == 1 {
                            Text(self.backStationName)
                                .font(.system(size: ViewStyle.FontSize.smallSize))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .opacity(self.nowAnimationPlaying ? 0 : self.backStationPostion.1)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Circle()
                            .stroke(Color.init(self.stationInfo.lineNumber))
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                            .offset(x: self.nowAnimationPlaying ?  self.nextStationPostion.0 : 1)
                        
                        let title = self.nextStationPostion.0 == 90 ? self.backStationName : self.arrivalDataList.first?.previousStation ?? "" 
                        Text(title)
                            .font(.system(size: ViewStyle.FontSize.smallSize))
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                            .opacity(self.nowAnimationPlaying ? 0 : self.nextStationPostion.1)
                    }
                }
                .padding(EdgeInsets(top: 11, leading: 20, bottom: 0, trailing: 20))
                .frame(maxWidth: .infinity)
                .frame(height: 73)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.init(self.stationInfo.lineNumber))
                        .frame(maxWidth: .infinity)
                        .frame(height: 5)
                        .offset(x: self.borderPostion)
                        .scaleEffect(x: self.borderSize)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 9, trailing: 20))
                }
            }
            .overlay {
                if Int(self.firstArrivalCode) != nil {
                    HStack {
                        Spacer()
                        Text(FixInfo.saveSetting.detailVCTrainIcon)
                            .font(.system(size: ViewStyle.FontSize.mainTitleSize))
                            .background {
                                Text(self.arrivalDataList.first?.isFast == "급행" ? "💨" : "")
                                    .font(.system(size: ViewStyle.FontSize.mediumSize))
                                    .offset(x: 15)
                            }
                            .offset(x: self.trainPostion, y: -15)
                            .opacity(self.isTrainIconShow ? 1 : 0)
                            .animation(.easeInOut(duration: 0.4), value: self.trainPostion)
                    }
                }
            }
            .padding(.bottom, 10)
            .clipped()
            
            MainStyleViewInSUI {
                VStack {
                    HStack(spacing: 15) {
                        let title = self.nowLoading ? "📡 열차 정보를 가져오고 있어요." : (self.arrivalDataList.first?.subPrevious == nil ||  self.arrivalDataList.first!.subPrevious.isEmpty)  ?  "⚠️ 실시간 정보가 없어요." : self.arrivalDataList.first!.subPrevious
                        Text(title)
                            .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                        
                        Spacer()
                        
                        Button(action: {
                            if !self.nowLoading {
                                self.refreshBtnTapped()
                                self.refreshBtnTapAnimation.toggle()
                                
                                Task {
                                    try? await Task.sleep(for: .milliseconds(550))
                                    self.refreshBtnTapAnimation.toggle()
                                }
                            }
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.init(uiColor: .label))
                        })
                        .overlay {
                            if let seconds = self.nowSeconds {
                                Text("\(seconds)")
                                    .font(.system(size: ViewStyle.FontSize.superSmallSize))
                            }
                        }
                        .rotationEffect(.init(degrees: self.refreshBtnTapAnimation ? 360 : 0))
                        .animation(.easeInOut(duration: self.refreshBtnTapAnimation ? 0.5 : 0), value: self.refreshBtnTapAnimation)
                        
                        if !self.isDisposable {
                            Button {
                                self.realtimeBtnTapped?()
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.init(uiColor: .label))
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    
                    if self.nowLoading {
                        VStack {
                            ProgressView()
                                .tint(Color("AppIconColor"))
                                .padding(.bottom, 5)
                        }
                        .frame(height: 108)
                    } else {
                        ForEach(Array(zip(self.arrivalDataList.indices, self.arrivalDataList)), id: \.0) { data in
                            let width = (self.screenWidthSize / 2) + 35
                            let text = data.0 == 0 ? data.1.detailArraivalViewText
                            : (self.stationInfo.exceptionLastStation.isEmpty ? data.1.detailArraivalViewText : "⛔️ 제외 행을 설정하면\n두 번째 열차를 볼 수 없어요."
                            )
                            let bgColor = data.0 == 0 ? Color(self.stationInfo.lineNumber)
                            : (self.stationInfo.exceptionLastStation.isEmpty ?
                               Color(self.stationInfo.lineNumber) : Color.init(uiColor: .lightGray)
                            )
                            let offset = data.0 == 0 ? -(self.screenWidthSize - (self.screenWidthSize / 2) + 35)  / 2 + 50
                            : (self.screenWidthSize - (self.screenWidthSize / 2) + 35)  / 2 - 50
                            
                            VStack(alignment: .center, spacing: 0) {
                                HStack {
                                    Text(text)
                                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .padding(.horizontal, 5)
                                    Spacer()
                                }
                                .frame(width: width,  height: 45)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(bgColor)
                                }
                                .offset(x: self.nowAnimationHalfPlaying ? offset + 35 : offset)
                                .opacity(self.nowAnimationHalfPlaying ? 0 : 1)
                                .padding(.bottom, 5)
                            }
                        }
                    }
                }
                .padding(15)
            }
        }
        .onChange(of: self.nowSeconds) {
            guard let _ = self.nowSeconds,
                  FixInfo.saveSetting.detailAutoReload,
                  self.firstArrivalCode == "3"
            else {return}
            
            withAnimation(.easeInOut(duration: 0.25)) {
                self.trainPostion -= 5.0
            }
        }
        .onChange(of: self.nowLoading) {
            self.isTrainIconShow = false
            
            if self.arrivalDataList.first?.previousStation == self.backStationName && self.arrivalDataList.first?.code == "99" {
                self.firstArrivalCode = "4" // 간헐적으로 API에서 코드(Code)를 잘못 방출하는 경우가 있음
            } else {
                self.firstArrivalCode = self.arrivalDataList.first?.code ?? "-"
            }
            
            if self.nowLoading {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.nextStationPostion = (100, 0)
                    self.backStationPostion = (-100, 0)
                }
            } else {
                self.trainPostion = 0
                
                if self.firstArrivalCode == "99" {
                    self.borderPostion = 35
                    self.borderSize = 1.2
                } else {
                    self.borderPostion = 12
                }
                
                let oppositionCode = (self.firstArrivalCode == "99" || Int(self.firstArrivalCode) == nil) ? "0" : "99"
                self.nextStationPostion = self.stationPositionMoveAndAlphaValue(code: oppositionCode, type: .next)
                self.backStationPostion = self.stationPositionMoveAndAlphaValue(code: oppositionCode, type: .back)
                
                self.nowAnimationPlaying = true
                self.nowAnimationHalfPlaying = true
                
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0).delay(0.4)) {
                        self.nowAnimationHalfPlaying = false
                    }
                    
                    withAnimation(.easeInOut(duration: 0.7)) {
                        self.backStationPostion = self.stationPositionMoveAndAlphaValue(code: self.firstArrivalCode, type: .back)
                        self.nextStationPostion = self.stationPositionMoveAndAlphaValue(code: self.firstArrivalCode, type: .next)
                        
                        if self.firstArrivalCode != "99" {
                            self.borderSize = 1.2
                            self.borderPostion = 35
                        } else {
                            self.borderSize = 1.0
                            self.borderPostion = 0
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.nowAnimationPlaying = false
                        self.borderSize = 1.0
                        self.borderPostion = 0
                        
                        if let code = Int(self.firstArrivalCode) {
                            self.isTrainIconShow = true
                            self.trainPostion = self.trainIconMoveValue(code: code)
                        }
                    }
                }
            }
        }
    }
}
// (0:진입, 1:도착, 2:출발, 3:전역출발, 4:전역진입, 5:전역도착, 99:운행중)
extension DetailArrivalView {
    enum StationType {
        case back, next
    }
    
    fileprivate func trainIconMoveValue(code: Int) -> CGFloat {
        let borderSize = UIScreen.main.bounds.width -  80
        switch code {
        case 0: // 첫번째역 바로 전
            return (-borderSize) + 17.5
        case 1: // 첫번째 역
            return (-borderSize)
        case 2: // 첫번째 역 지나침
            return (-borderSize) - 10
        case 3: // 이동 (애니메이션 처리):
            return (-borderSize / 2)
        case 4: //  3번째역 바로 전
            return  2.5
        default: // 3번째 역
            return -15
        }
    }
    
    fileprivate func stationPositionMoveAndAlphaValue(code: String, type: StationType) -> (CGFloat, Double)  {
        let borderSize = self.screenWidthSize
        guard let intCode = Int(code) else {
            if type == .next {
                return (1, 1)
            } else {
                return (borderSize - self.defaultStationWidth - 30 - 13 - 20 - 21, 0)
            }
        }
        
        if intCode < 6 && type  == .back {
            return (borderSize - self.defaultStationWidth - 30 - 13 - 20 - 21, 0) // 2개의 역만 필요
        } else if type == .back  {
            return (1, 1)
        }
        
        if intCode < 6 && type == .next {
            return (90, 1)
        } else if type == .next {
            return (1, 1)
        }
        
        return (0, 0)
    }
}

#Preview {
    let realOne = RealtimeStationArrival(upDown: "상행", arrivalTime: "3분", previousStation: "고속터미널", subPrevious: "1", code: "0", subWayId: "1003", stationName: "교대", lastStation: "구파발", lineNumber: "3", isFast: nil, backStationId: "1003000339", nextStationId: "1003000341", trainCode: "99")
    let realTwo = RealtimeStationArrival(upDown: "상행", arrivalTime: "10분", previousStation: "매봉", subPrevious: "", code: "99", subWayId: "1003", stationName: "교대", lastStation: "오금", lineNumber: "3", isFast: nil, backStationId: "1003000339", nextStationId: "1003000341", trainCode: "99")
    DetailArrivalView(
        arrivalDataList: [
            .init(realTimeStationArrival: realOne, backStationName: "남부터미널", nextStationName: "고속터미널", nowStateMSG: realOne.useState),
            .init(realTimeStationArrival: realTwo, backStationName: "남부터미널", nextStationName: "고속터미널", nowStateMSG: realTwo.useState),
        ], stationInfo: .init(upDown: "상행", stationName: "340", lineNumber: "03호선", stationCode: "340", lineCode: "1003", exceptionLastStation: "", korailCode: ""),
        backStationName: "남부터미널",
        nowLoading: false,
        isDisposable: false,
        refreshBtnTapped: {}
    )
}
