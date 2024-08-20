// Copyright 2024 Arm Ltd. and/or its affiliates

#pragma once

#include "kai_pack.h"
#include "kai_ukernel_interface.h"

#if AT_KLEIDIAI_ENABLED()

namespace at::native::kleidiai {

Tensor kai_pack_rhs(
    const Tensor& weight_packed,
    const Tensor& weight,
    const Tensor& scales,
    const int64_t n,
    const int64_t k,
    const int64_t bl);

size_t kai_pack_rhs_size(const int64_t n, const int64_t k, const int64_t bl);

void kai_quant_pack_lfs_mm_channelwise(
    const Tensor& output,
    const Tensor& input,
    const Tensor& weight,
    const int64_t m,
    const int64_t n,
    const int64_t k);

void kai_quant_pack_lfs_mm_groupwise(
    const Tensor& output,
    const Tensor& input,
    const Tensor& weight,
    const int64_t m,
    const int64_t n,
    const int64_t k,
    const int64_t bl);

} // namespace at::native::kleidiai
#endif
