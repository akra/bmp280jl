using StructIO

const BMP280_CONTROL_REG = 0xF4
const BMP280_CONFIG_REG = 0xF5

const BMP280_DATA_REG = 0xF7
const BMP280_DATA_SIZE = 6
const BMP280_ID_REG = 0xD0
const BMP280_COEF_REG = 0x88


const BMP280_OVERSAMPLE_TEMP = 0x8
const BMP280_OVERSAMPLE_PRES = 0x2
const BMP280_MODE = 0x3

@io struct BMP280_Coefficients
   size::UInt8
   dig_T1::UInt16
   dig_T2::Int16
   dig_T3::Int16
   dig_P1::UInt16
   dig_P2::Int16
   dig_P3::Int16
   dig_P4::Int16
   dig_P5::Int16
   dig_P6::Int16
   dig_P7::Int16
   dig_P8::Int16
   dig_P9::Int16
end align_packed

struct BMP280_Measurings
   temp::Float32
   pressure::Float32
end

struct BMP280
   devId::Int
   chipId::UInt8
   coef::BMP280_Coefficients
end
