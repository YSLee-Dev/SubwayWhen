//
//  ModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

class ModalViewModel {
    // MODEL
    let model = ModalModel()
    
    // OUTPUT
    let modalData : Driver<ResultVCCellData>
    let modalClose : Driver<Void>
    
    // INPUT
    let clickCellData = PublishRelay<ResultVCCellData>()
    let upDownBtnClick = PublishRelay<Bool>()
    let grayBgClick = PublishRelay<Void>()
    let groupClick = BehaviorRelay<SaveStationGroup>(value: .one)
    let exceptionLastStationText = BehaviorRelay<String?>(value: "")
    
    // NOW MODAL CLOSE
    let totalModalClose = PublishRelay<Void>()
    
    let bag = DisposeBag()
    
    init(){
        self.modalData = self.clickCellData
            .asDriver(onErrorDriveWith: .empty())
        
        // 전체 데이터를 합친 후, SaveStation 타입으로 반환
        let saveStationInfo = Observable
            .combineLatest(clickCellData, self.groupClick, self.exceptionLastStationText, self.upDownBtnClick){ cellData, group, exception, updown -> SaveStation in
                
                var updownLine = ""
                if cellData.useLine ==  "2호선" {
                    updownLine = updown ? "내선" : "외선"
                }else{
                    updownLine = updown ? "상행" : "하행"
                }
                
                return SaveStation(id: UUID().uuidString, stationName: cellData.stationName, stationCode: cellData.stationCode, updnLine: updownLine, line: cellData.lineNumber, lineCode: cellData.lineCode, group: group, exceptionLastStation: exception ?? "", totalStationCode: cellData.totalStation)
            }
      
        self.modalClose = Observable
            .merge(
                self.grayBgClick.asObservable(),
                self.totalModalClose.asObservable()
            )
            .asDriver(onErrorDriveWith: .empty())
        
        // TAGO Station ID 통신
        let totalStationCodeData = self.clickCellData
            .withUnretained(self)
            .flatMap{ viewModel, data in
                viewModel.model.totalStationSearchRequest(data.stationName)
            }
            .map{ data -> TotalStationSearch? in
                guard case let .success(value) = data else {
                    return nil
                }
                print(value)
                return value
            }
            .filterNil()
            .map{
                $0.response.body.items.item
            }
        
        // FixInfo에 저장
        saveStationInfo
              .withLatestFrom(totalStationCodeData){info, totalData in
                  var saveInfo = info
                  for x in totalData{
                      if x.subwayStationName.contains(info.stationName) && x.subwayRouteName == info.totalStationCode{
                          saveInfo.totalStationCode = x.subwayStationId
                      }
                  }
                  print(saveInfo.totalStationCode)
                  FixInfo.saveStation.append(saveInfo)
                  return Void()
              }
              .bind(to: self.totalModalClose)
              .disposed(by: self.bag)
    }
}
