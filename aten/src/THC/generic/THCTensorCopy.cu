#ifndef THC_GENERIC_FILE
#define THC_GENERIC_FILE "THC/generic/THCTensorCopy.cu"
#else

void THCTensor_(copy)(THCState* state, THCTensor* dst, THCTensor* src) {
  if (dst == src) return;
  at::Tensor dst_wrap = THTensor_wrap(dst);
  at::Tensor src_wrap = THTensor_wrap(src);
  at::native::copy_(dst_wrap, src_wrap);
}

template <>
THCTensor *THCTensor_newClone<scalar_t>(THCState *state, THCTensor *self) {
  THCTensor* tensor =
      // THCTensor_new(state, THTensor_getStoragePtr(self)->dtype());
      THCTensor_new(state, self->dtype());
  THCTensor_resizeAs(state, tensor, self);
  at::Tensor tensor_wrap = THTensor_wrap(tensor);
  at::Tensor self_wrap = THTensor_wrap(self);
  at::native::copy_(tensor_wrap, self_wrap);
  return tensor;
}

template <>
THCTensor *THCTensor_newContiguous<scalar_t>(THCState *state, THCTensor *self)
{
  if(!self->is_contiguous()) {
    return THCTensor_newClone<scalar_t>(state, self);
  } else {
    THCTensor_retain(state, self);
    return self;
  }
}


template <>
void THCTensor_freeCopyTo<scalar_t>(THCState *state, THCTensor *self, THCTensor *dst) {
  if(self != dst) {
    at::Tensor dst_wrap = THTensor_wrap(dst);
    at::Tensor self_wrap = THTensor_wrap(self);
    at::native::copy_(dst_wrap, self_wrap);
  }

  THCTensor_free(state, self);
}

#endif
