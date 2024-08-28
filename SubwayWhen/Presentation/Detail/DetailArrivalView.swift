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
    private let screenWidthSize = UIScreen.main.bounds.width -  40
    
    var arrivalDataList: [RealtimeStationArrival]
    let stationInfo: ScheduleSearch
    let stationName: String
    let backStationName: String
    var nowLoading: Bool
    let refreshBtnTapped: () -> ()
    
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
                HStack(spacing: 50) {
                    VStack(alignment: .leading, spacing: 5) {
                        Circle()
                            .stroke(Color.init(self.stationInfo.line))
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                        
                        Text(self.stationName)
                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .bold))
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Circle()
                            .stroke(Color.init(self.stationInfo.line))
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                            .offset(x: self.backStationPostion.0)
                            .opacity(self.nowAnimationPlaying ? 1 : self.backStationPostion.1)
                        
                        Text(self.backStationName)
                            .font(.system(size: ViewStyle.FontSize.smallSize))
                            .opacity(self.nowAnimationPlaying ? 0 : self.backStationPostion.1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Circle()
                            .stroke(Color.init(self.stationInfo.line))
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                            .offset(x: self.nowAnimationPlaying ?  self.nextStationPostion.0 : 1)
                        
                        let title = self.nextStationPostion.0 == 90 ? self.backStationName : self.arrivalDataList.first?.previousStation ?? "" 
                        Text(title)
                            .font(.system(size: ViewStyle.FontSize.smallSize))
                            .opacity(self.nowAnimationPlaying ? 0 : self.nextStationPostion.1)
                    }
                }
                .padding(EdgeInsets(top: 11, leading: 20, bottom: 0, trailing: 20))
                .frame(maxWidth: .infinity)
                .frame(height: 73)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.init(self.stationInfo.line))
                        .frame(maxWidth: .infinity)
                        .frame(height: 5)
                        .offset(x: self.borderPostion)
                        .scaleEffect(x: self.borderSize)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 9, trailing: 20))
                }
            }
            .overlay {
                if Int(self.arrivalDataList.first?.code ?? "") != nil {
                    HStack {
                        Spacer()
                        Text(FixInfo.saveSetting.detailVCTrainIcon)
                            .font(.system(size: ViewStyle.FontSize.mainTitleSize))
                            .offset(x: self.trainPostion, y: -15)
                            .opacity(self.nowAnimationPlaying ? 0 : 1)
                            .animation(.easeInOut(duration: 0.5), value: self.trainPostion)
                    }
                }
            }
            .padding(.bottom, 10)
            
            MainStyleViewInSUI {
                VStack {
                    HStack {
                        let title = (self.arrivalDataList.first?.subPrevious == nil ||  self.arrivalDataList.first!.subPrevious.isEmpty)  ?  "⚠️ 실시간 정보없음" : self.arrivalDataList.first!.subPrevious
                        Text(title)
                            .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                        
                        Spacer()
                        
                        Button(action: {
                            self.refreshBtnTapped()
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.init(uiColor: .label))
                        })
                    }
                    .padding(.bottom, 10)
                    
                    ForEach(Array(zip(self.arrivalDataList.indices, self.arrivalDataList)), id: \.0) { data in
                        let width = (self.screenWidthSize / 2) + 35
                        VStack(alignment: .center, spacing: 0) {
                            HStack {
                                Text(data.1.detailArraivalViewText)
                                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .padding(.horizontal, 5)
                                Spacer()
                            }
                            .frame(width: width,  height: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(self.stationInfo.line))
                            }
                            .offset(
                                x: data.0 == 0 ? -(self.screenWidthSize - (self.screenWidthSize / 2) + 35)  / 2 + 50
                                : (self.screenWidthSize - (self.screenWidthSize / 2) + 35)  / 2 - 50
                            )
                            .padding(.bottom, 5)
                        }
                    }
                }
                .padding(15)
            }
        }
        .onChange(of: self.nowLoading) {
            let code = self.arrivalDataList.first?.code ?? "-"
            self.trainPostion  = 0
            
            withAnimation(.easeInOut(duration: 0)) {
                let oppositionCode = (code == "99" || Int(code) == nil) ? "0" : "99"
                self.nextStationPostion = self.stationPositionMoveAndAlphaValue(code: oppositionCode, type: .next)
                self.backStationPostion = self.stationPositionMoveAndAlphaValue(code: oppositionCode, type: .back)
                if code == "99" {
                    self.borderSize = 1.2
                    self.borderPostion = 35
                } else {
                    self.borderPostion = 15
                }
                self.nowAnimationPlaying = true
            } completion: {
                withAnimation(.easeInOut(duration: 0.7)) {
                    self.backStationPostion = self.stationPositionMoveAndAlphaValue(code: code, type: .back)
                    self.nextStationPostion = self.stationPositionMoveAndAlphaValue(code: code, type: .next)
                    
                    if code != "99" {
                        self.borderSize = 1.2
                        self.borderPostion = 35
                    } else {
                        self.borderSize = 1.0
                        self.borderPostion = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.69) {
                        self.nowAnimationPlaying = false
                        self.borderSize = 1.0
                        self.borderPostion = 0
                        
                        if let code = Int(self.arrivalDataList.first?.code ?? "") {
                            self.trainPostion =  self.trainIconMoveValue(code: code)
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
            return (-borderSize) + 10
        case 1: // 첫번째 역
            return (-borderSize)
        case 2: // 첫번째 역 지나침
            return (-borderSize) - 10
        case 3: // 이동 (애니메이션 처리):
            return (-borderSize / 2)
        case 4: //  3번째역 바로 전
            return  0
        default: // 3번째 역
            return -15
        }
    }
    
    fileprivate func stationPositionMoveAndAlphaValue(code: String, type: StationType) -> (CGFloat, Double)  {
        let borderSize = self.screenWidthSize
        guard let intCode = Int(code) else {
            if type == .next {
                return (0, 1)
            } else {
                return (borderSize - 125, 0)
            }
        }
        
        if intCode < 6 && type  == .back {
            return (borderSize - 125, 0) // 2개의 역만 필요
        } else if type == .back  {
            return (0, 1)
        }
        
        if intCode < 6 && type == .next {
            return (90, 1)
        } else if type == .next {
            return (0, 1)
        }
        
        return (0, 0)
    }
}

#Preview {
    DetailArrivalView(arrivalDataList: [
        .init(upDown: "상행", arrivalTime: "3분", previousStation: "고속터미널", subPrevious: "", code: "1", subWayId: "1003", stationName: "교대", lastStation: "구파발", lineNumber: "3", isFast: nil, backStationId: "1003000339", nextStationId: "1003000341", trainCode: "99"),
                                  .init(upDown: "상행", arrivalTime: "10분", previousStation: "매봉", subPrevious: "", code: "99", subWayId: "1003", stationName: "교대", lastStation: "오금", lineNumber: "3", isFast: nil, backStationId: "1003000339", nextStationId: "1003000341", trainCode: "99")
    ], stationInfo: ScheduleSearch(stationCode: "340", upDown: "상행", exceptionLastStation: "", line: "03호선", korailCode: ""), stationName: "교대", backStationName: "남부터미널", nowLoading: false
    ) {}
}
