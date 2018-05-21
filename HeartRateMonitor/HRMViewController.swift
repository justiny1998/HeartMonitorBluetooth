//
//  ViewController.swift
//  BluetoothDemo
//
//  Created by Young, Justin on 5/21/18.
//  Copyright © 2018 Young, Justin. All rights reserved.
//

import UIKit
import CoreBluetooth
let heartRateServiceCBUUID = CBUUID(string: "0x180D")

class HRMViewController: UIViewController {

  @IBOutlet weak var heartRateLabel: UILabel!
  @IBOutlet weak var bodySensorLocationLabel: UILabel!
  var centralManager: CBCentralManager!
  var heartRatePeripheral: CBPeripheral!

  override func viewDidLoad() {
    centralManager = CBCentralManager(delegate: self, queue: nil)
    super.viewDidLoad()

    // Make the digits monospaces to avoid shifting when the numbers change
    heartRateLabel.font = UIFont.monospacedDigitSystemFont(ofSize: heartRateLabel.font!.pointSize, weight: .regular)
  }

  func onHeartRateReceived(_ heartRate: Int) {
    heartRateLabel.text = String(heartRate)
    print("BPM: \(heartRate)")
  }
}

extension HRMViewController: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    //default
    switch central.state {
    case .unknown:
      print("central.state is .unknown")
    case .resetting:
      print("central.state is .resetting")
    case .unsupported:
      print("central.state is .unsupported")
    case .unauthorized:
      print("central.state is .unauthorized")
    case .poweredOff:
      print("central.state is .poweredOff")
    case .poweredOn:
      print("central.state is .poweredOn")
      centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print(peripheral)
    //Set a reference to the located HM peripheral
    heartRatePeripheral = peripheral
    heartRatePeripheral.delegate = self
    //Stop scanning once HM peripheral is found
    centralManager.stopScan()
    //Connect to HM peripheral
    centralManager.connect(heartRatePeripheral)
  }
  
  //Prints "Connection Successful" if connected to GDO
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("Connection Successful.")
    heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
  }
}

extension HRMViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }
    for service in services {
      print(service)
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                  error: Error?) {
    guard let characteristics = service.characteristics else { return }
    for characteristic in characteristics {
      print(characteristic)
    }
  }
}
