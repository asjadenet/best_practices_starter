#include <catch2/catch_test_macros.hpp>

#include <best_practices_starter/sample_library.hpp>

#ifndef __MACH__
TEST_CASE("Factorials are computed with constexpr", "[factorial]")
{

	  STATIC_REQUIRE(factorial_constexpr(0) == 1);
	  STATIC_REQUIRE(factorial_constexpr(1) == 1);
	  STATIC_REQUIRE(factorial_constexpr(2) == 2);
	  STATIC_REQUIRE(factorial_constexpr(3) == 6);
	  STATIC_REQUIRE(factorial_constexpr(10) == 3628800);
}
#endif