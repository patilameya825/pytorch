// Copyright 2024 Arm Ltd. and/or its affiliates

#pragma once
#include <ATen/Config.h>
#include <ATen/core/Tensor.h>
#include <ATen/ops/empty.h>
#include <torch/library.h>
#if AT_KLEIDIAI_ENABLED()

namespace at::native::kleidiai {

template <typename T>
Tensor kai_pack_rhs_groupwise_int4(
    T& kernel,
    const Tensor& weight_packed,
    const Tensor& weight,
    const int64_t n,
    const int64_t k,
    const int64_t bl) {
  // kai supports 32 block size only
  const auto& ukernel = kernel.ukernel;
  const size_t nr = ukernel.get_nr();
  const size_t kr = ukernel.get_kr();
  const size_t sr = ukernel.get_sr();
  auto weight_packed_data =
      reinterpret_cast<uint8_t*>(weight_packed.data_ptr());
  const auto weight_data = weight.data_ptr<uint8_t>();

  auto& params = kernel.rhs_pack_params;
  params.lhs_zero_point = 1;
  params.rhs_zero_point = 8;
  kernel.kai_run_rhs_pack(
      1,
      n,
      k,
      nr,
      kr,
      sr,
      bl,
      (const uint8_t*)(weight_data),
      NULL,
      weight_packed_data,
      0,
      &params);
  return weight_packed;
}

template <typename T>
Tensor kai_pack_rhs_channelwise_int4(
    T& kernel,
    const Tensor& weight_packed,
    const Tensor& weight,
    const Tensor& scales,
    const int64_t n,
    const int64_t k) {
  const auto& ukernel = kernel.ukernel;
  const size_t nr = ukernel.get_nr();
  const size_t kr = ukernel.get_kr();
  const size_t sr = ukernel.get_sr();
  auto weight_packed_data =
      reinterpret_cast<uint8_t*>(weight_packed.data_ptr());
  const auto weight_data = weight.data_ptr<uint8_t>();
  const auto scales_data = scales.data_ptr<float>();

  auto& params = kernel.rhs_pack_params;
  params.lhs_zero_point = 1;
  params.rhs_zero_point = 8;
  kernel.kai_run_rhs_pack(
      1,
      n,
      k,
      nr,
      kr,
      sr,
      (const uint8_t*)(weight_data),
      NULL,
      (const float*)(scales_data),
      weight_packed_data,
      0,
      &params);
  return weight_packed;
}

} // namespace at::native::kleidiai

#endif
