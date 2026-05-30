module NumDual

export Dual, dual, fun, der

struct Dual{T<:Real}
	fun::T
	der::T
end