module bmp280

  using BaremetalPi
  include("./constants.jl")

  function init(device::String, address::UInt8)
    init_i2c(device)
    return init(1, address)
  end

  function init(devId::Int, address::UInt8)
    i2c_slave(devId, address)
    control = BMP280_OVERSAMPLE_TEMP<<5 | BMP280_OVERSAMPLE_PRES<<2 | BMP280_MODE
    i2c_smbus_write_byte_data(devId, BMP280_CONTROL_REG, control)
    chipId = i2c_smbus_read_byte_data(devId, BMP280_ID_REG)
    data = i2c_smbus_read_i2c_block_data(devId,BMP280_COEF_REG,sizeof(BMP280_Coefficients)-1)
    buffer = IOBuffer(data)
    coef = unpack(buffer, BMP280_Coefficients)
    return BMP280(devId, chipId, coef)
  end

  function read(device::BMP280, wait::Bool)
      if wait
          wait_time = 1.25 + (2.3 * BMP280_OVERSAMPLE_TEMP) + ((2.3 * BMP280_OVERSAMPLE_PRES) + 0.575)
          sleep(wait_time/1000)
      end
      data = i2c_smbus_read_i2c_block_data(device.devId,BMP280_DATA_REG,BMP280_DATA_SIZE)
      UP = ((Int32(data[2]) << 16) | (Int32(data[3]) << 8) | (Int32(data[4]) & 0xF0)) >> 4
      UT = ((Int32(data[5]) << 16) | (Int32(data[6]) << 8) | (Int32(data[7]) & 0xF0)) >> 4

      var1 = ((((UT>>3)-(device.coef.dig_T1<<1)))*(device.coef.dig_T2)) >> 11
      var2 = (((((UT>>4) - (device.coef.dig_T1)) * ((UT>>4) - (device.coef.dig_T1))) >> 12) * (device.coef.dig_T3)) >> 14
      t_fine = var1+var2
      temp = Float32(((t_fine * 5) + 128) >> 8)
     
      var1 = t_fine / 2.0 - 64000.0
      var2 = var1 * var1 * device.coef.dig_P6 / 32768.0
      var2 = var2 + var1 * device.coef.dig_P5 * 2.0
      var2 = var2 / 4.0 + device.coef.dig_P4 * 65536.0
      var1 = (device.coef.dig_P3 * var1 * var1 / 524288.0 + device.coef.dig_P2 * var1) / 524288.0
      var1 = (1.0 + var1 / 32768.0) * device.coef.dig_P1
      if var1 == 0
        pressure=0
      else
        pressure = 1048576.0 - UP
        pressure = ((pressure - var2 / 4096.0) * 6250.0) / var1
        var1 = device.coef.dig_P9 * pressure * pressure / 2147483648.0
        var2 = pressure * device.coef.dig_P8 / 32768.0
        pressure = pressure + (var1 + var2 + device.coef.dig_P7) / 16.0
      end

      return BMP280_Measurings(temp/100.0,pressure/100.0)
  end

  function 

  close(device::BMP280)
    i2c_close(device.devId)
  end

end
