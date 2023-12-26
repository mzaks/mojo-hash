from math.bit import bit_length
# from utils.list import VariadicList
from collections.vector import DynamicVector

struct FibyTree[T: CollectionElement, cmp: fn(a:T, b:T) -> Int, to_str: fn(T) -> String](Sized):
    alias Union = 0
    alias Intersection = 1
    alias Difference = 2
    alias SymetricDifference = 3
    alias OtherDifference = 4
    alias IsDisjoint = 5
    alias IsSubset = 6
    alias IsSuperset = 7

    var elements: DynamicVector[T]
    var left: DynamicVector[UInt32]
    var right: DynamicVector[UInt32]
    var deleted: Int
    var max_depth: UInt32
    var balanced: Bool
    
    fn __init__(inout self):
        self.elements = DynamicVector[T]()
        self.left = DynamicVector[UInt32]()
        self.right = DynamicVector[UInt32]()
        self.deleted = 0
        self.max_depth = 0
        self.balanced = False
        
        # let elements_list: VariadicList[T] = elements
        # for i in range(len(elements_list)):
        #     self.add(elements[i])

    fn __moveinit__(inout self, owned existing: Self):
        self.elements = existing.elements
        self.left = existing.left
        self.right = existing.right
        self.deleted = existing.deleted
        self.max_depth = existing.max_depth
        self.balanced = existing.balanced
    
    @always_inline("nodebug")
    fn has_left(self, parent: UInt32) -> Bool:
        return (self.left[parent.to_int()] != parent).__bool__()

    @always_inline("nodebug")
    fn has_right(self, parent: UInt32) -> Bool:
        return (self.right[parent.to_int()] != parent).__bool__()
        
    fn add(inout self, element: T):
        if self.__len__() == 0:
            self._set_root(element)
            self._set_max_depth(1)
            return
        var parent = 0
        var depth: UInt32 = 1
        while True:
            let diff = cmp(self.elements[parent], element)
            if diff == 0:
                return
            depth += 1
            if diff > 0:
                let left = self.left[parent].to_int()
                if left == parent:
                    self._add_left(parent, element)
                    break
                else:
                    parent = left
            else:
                let right = self.right[parent].to_int()
                if right == parent:
                    self._add_right(parent, element)
                    break
                else:
                    parent = right
        
        self.balanced = False
        self._set_max_depth(depth)
        if self.max_depth > self._optimal_depth() ** 2:
            self.balance()
    
    @always_inline("nodebug")
    fn _set_max_depth(inout self, candidate: UInt32):
        if self.max_depth < candidate:
            self.max_depth = candidate
    
    fn _optimal_depth(self) -> UInt32:
        return bit_length(UInt32(self.__len__()))
    
    @always_inline("nodebug")
    fn _set_root(inout self, element: T):
        if len(self.elements) == 0:
            self.elements.push_back(element)
            self.left.push_back(0)
            self.right.push_back(0)
        else:
            self.elements[0] = element
            self.left[0] = 0
            self.right[0] = 0
            if self.deleted > 0:
                self.deleted -= 1
           
    @always_inline("nodebug")
    fn _add_left(inout self, parent: UInt32, element: T):
        let index = len(self.elements)
        self.elements.push_back(element)
        self.left.push_back(index)
        self.right.push_back(index)
        self.left[parent.to_int()] = index
    
    @always_inline("nodebug")
    fn _add_right(inout self, parent: UInt32, element: T):
        let index = len(self.elements)
        self.elements.push_back(element)
        self.left.push_back(index)
        self.right.push_back(index)
        self.right[parent.to_int()] = index
    
    @always_inline("nodebug")
    fn delete(inout self, element: T) -> Bool:
        let index_tuple = self._get_index(element)
        let parent = index_tuple.get[0, Int]()
        let index = index_tuple.get[1, Int]()
        if index == -1:
            return False
        
        self.balanced = False
        
        if self._is_leaf(index):
            self._delete_leaf(index, parent)
            return True
        
        if self.has_left(index) and not self.has_right(index):
            if index == 0:
                let left = self.left[0]
                self.elements[0] = self.elements[left.to_int()]
                if self.has_left(left):
                    self.left[0] = self.left[left.to_int()]
                else:
                    self.left[0] = 0
                if self.has_right(left):
                    self.right[0] = self.right[left.to_int()]
                else:
                    self.right[0] = 0
            else:
                if self.left[parent] == index:
                    self.left[parent] = self.left[index]
                else:
                    self.right[parent] = self.left[index]
            self.deleted += 1
            return True
        
        if self.has_right(index) and not self.has_left(index):
            if index == 0:
                let right = self.right[0]
                self.elements[0] = self.elements[right.to_int()]
                if self.has_left(right):
                    self.left[0] = self.left[right.to_int()]
                else:
                    self.left[0] = 0
                if self.has_right(right):
                    self.right[0] = self.right[right.to_int()]
                else:
                    self.right[0] = 0
            else:
                if self.left[parent] == index:
                    self.left[parent] = self.right[index]
                else:
                    self.right[parent] = self.right[index]
            self.deleted += 1
            return True
            
        return self._swap_with_next_smaller_leaf(index)
    
    @always_inline("nodebug")
    fn sorted_elements(self) -> DynamicVector[T]:
        let number_of_elements = self.__len__()
        var result = DynamicVector[T](number_of_elements)
        if number_of_elements == 0:
            return result
        var stack = DynamicVector[UInt32](self.max_depth.to_int())
        var current: UInt32 = 0
        while len(result) < number_of_elements:
            if len(result) == 0 or cmp(result[len(result) - 1], self.elements[self.left[current.to_int()].to_int()]) < 0:
                while self.has_left(current):
                    stack.push_back(current)
                    current = self.left[current.to_int()]
            result.append(self.elements[current.to_int()])
            if self.has_right(current):
                current = self.right[current.to_int()]
            else:
                current = stack.pop_back()
        
        return result
    
    fn clear(inout self):
        self.elements.clear()
        self.left.clear()
        self.right.clear()
        self.deleted = 0
        self.max_depth = 0
        self.balanced = False
    
    fn union(self, other: Self) -> Self:
        var result = Self()
        let combined: DynamicVector[T]
        if other.__len__() == 0:
            combined = self.sorted_elements()
        elif self.__len__() == 0:
            combined = other.sorted_elements()
        else:
            combined = self._combine[Self.Union](other)
        result._balance_with(combined)
        return result^
    
    fn union_inplace(inout self, other: Self):
        if other.__len__() == 0:
            return
        if self.__len__() == 0:
            self._balance_with(other.sorted_elements())
            return
        let combined = self._combine[Self.Union](other)
        self._balance_with(combined)
    
    fn intersection(self, other: Self) -> Self:
        var result = FibyTree[T, cmp, to_str]()
        if other.__len__() == 0:
            return result^
        if self.__len__() == 0:
            return result^
        let combined = self._combine[Self.Intersection](other)
        result._balance_with(combined)
        return result^
    
    fn intersection_inplace(inout self, other: Self):
        if other.__len__() == 0:
            self.clear()
            return
        if self.__len__() == 0:
            self.clear()
            return
        let combined = self._combine[Self.Intersection](other)
        self._balance_with(combined)
        
    fn difference(self, other: Self) -> Self:
        var result = FibyTree[T, cmp, to_str]()
        let combined: DynamicVector[T]
        if other.__len__() == 0 or self.__len__() == 0:
            combined = self.sorted_elements()
        else:
            combined = self._combine[Self.Difference](other)
        result._balance_with(combined)
        return result^
        
    fn difference_inplace(inout self, other: Self):
        if other.__len__() == 0 or self.__len__() == 0:
            return
        let combined = self._combine[Self.Difference](other)
        self._balance_with(combined)
        
    fn other_difference_inplace(inout self, other: Self):
        if other.__len__() == 0:
            self.clear()
            return
        if self.__len__() == 0:
            self._balance_with(other.sorted_elements())
            return
        let combined = self._combine[Self.OtherDifference](other)
        self._balance_with(combined)
    
    fn symmetric_difference(self, other: Self) -> Self:
        var result = FibyTree[T, cmp, to_str]()
        let combined: DynamicVector[T]
        if other.__len__() == 0:
            combined = self.sorted_elements()
        elif self.__len__() == 0:
            combined = other.sorted_elements()
        else: 
            combined = self._combine[Self.SymetricDifference](other)
        result._balance_with(combined)
        return result^
    
    fn symmetric_difference_inplace(inout self, other: Self):
        if other.__len__() == 0:
            return
        if self.__len__() == 0:
            self._balance_with(other.sorted_elements())
            return
        let combined = self._combine[Self.SymetricDifference](other)
        self._balance_with(combined)
    
    @always_inline("nodebug")
    fn _combine[type: Int](self, other: Self) -> DynamicVector[T]:
        let num1 = self.__len__()
        let num2 = other.__len__()
        # assert(num1 > 0)
        # assert(num2 > 0)
        var combined = DynamicVector[T](num1 + num2)
        var cur1: UInt32 = 0
        var cur2: UInt32 = 0
        var stack1 = DynamicVector[UInt32](self.max_depth.to_int())
        var stack2 = DynamicVector[UInt32](other.max_depth.to_int())
        var last_returned1 = DynamicVector[T](1)
        var last_returned2 = DynamicVector[T](1)
        var e1 = self._sorted_iter(cur1, stack1, last_returned1)
        last_returned1.append(e1)
        var e2 = other._sorted_iter(cur2, stack2, last_returned2)
        last_returned2.append(e2)
        var compute1 = False
        var compute2 = False
        var cursor1 = 1
        var cursor2 = 1
        var increase1 = False
        var increase2 = False
        while True:
            if compute1 and cursor1 < num1:
                e1 = self._sorted_iter(cur1, stack1, last_returned1)
                last_returned1.clear()
                last_returned1.append(e1)
                increase1 = True
            if compute2 and cursor2 < num2:
                e2 = other._sorted_iter(cur2, stack2, last_returned2)
                last_returned2.clear()
                last_returned2.append(e2)
                increase2 = True
            let diff = cmp(e1, e2)
            if diff < 0:
                if num1 == 1 and num2 == 1:
                    @parameter 
                    if type == Self.Union or type == Self.Difference or type == Self.SymetricDifference:
                        combined.append(e1)
                    @parameter 
                    if type == Self.Union or type == Self.SymetricDifference or type == Self.OtherDifference:
                        combined.append(e2)
                    break
                if cursor1 < num1:
                    @parameter 
                    if type == Self.Union or type == Self.Difference or type == Self.SymetricDifference:
                        if len(combined) == 0 or cmp(combined[len(combined) - 1], e1) < 0:
                            combined.append(e1)
                    compute1 = cursor1 < num1
                    compute2 = False
                else:
                    @parameter 
                    if type == Self.Union or type == Self.SymetricDifference or type == Self.OtherDifference:
                        if len(combined) == 0 or cmp(combined[len(combined) - 1], e2) < 0:
                            combined.append(e2)
                    compute1 = False
                    compute2 = cursor2 < num2
            elif diff > 0:
                if num1 == 1 and num2 == 1:
                    @parameter 
                    if type == Self.Union or type == Self.SymetricDifference or type == Self.OtherDifference:
                        combined.append(e2)
                    @parameter 
                    if type == Self.Union or type == Self.Difference or type == Self.SymetricDifference:
                        combined.append(e1)
                    break
                if cursor2 < num2:
                    @parameter 
                    if type == Self.Union or type == Self.SymetricDifference or type == Self.OtherDifference:
                        if len(combined) == 0 or cmp(combined[len(combined) - 1], e2) < 0:
                            combined.append(e2)
                    compute1 = False
                    compute2 = cursor2 < num2
                else:
                    @parameter 
                    if type == Self.Union or type == Self.Difference or type == Self.SymetricDifference:
                        if len(combined) == 0 or cmp(combined[len(combined) - 1], e1) < 0:
                            combined.append(e1)
                    compute1 = cursor1 < num1
                    compute2 = False
            else:
                @parameter 
                if type == Self.Union or type == Self.Intersection:
                    if len(combined) == 0 or cmp(combined[len(combined) - 1], e1) < 0:
                        combined.append(e1)
                compute1 = cursor1 < num1
                compute2 = cursor2 < num2
            
            if increase1 and cursor1 < num1:
                cursor1 += 1
                increase1 = False
            if increase2 and cursor2 < num2:
                cursor2 += 1
                increase2 = False
            @parameter 
            if type == Self.Intersection:
                if cursor1 >= num1 or cursor2 >= num2:
                    break
            else:
                if cursor1 >= num1 and cursor2 >= num2:
                    break
                
        return combined
    
    fn is_subset(self, other: Self) -> Bool:
        return self._check[Self.IsSubset](other)
    
    fn is_superset(self, other: Self) -> Bool:
        return self._check[Self.IsSuperset](other)
    
    fn is_disjoint(self, other: Self) -> Bool:
        return self._check[Self.IsDisjoint](other)
    
    @always_inline("nodebug")
    fn _check[type: Int](self, other: Self) -> Bool:
        let num1 = self.__len__()
        let num2 = other.__len__()
        @parameter
        if type == Self.IsSubset:
            if num1 == 0:
                return True
            if num1 > num2 or num2 == 0:
                return False
        @parameter
        if type == Self.IsSuperset:
            if num2 == 0:
                return True
            if num1 < num2 or num1 == 0:
                return False
            
        @parameter
        if type == Self.IsDisjoint:
            if num1 == 0 or num2 == 0:
                return True

        var cur1: UInt32 = 0
        var cur2: UInt32 = 0
        var stack1 = DynamicVector[UInt32](self.max_depth.to_int())
        var stack2 = DynamicVector[UInt32](other.max_depth.to_int())
        var last_returned1 = DynamicVector[T](1)
        var last_returned2 = DynamicVector[T](1)
        var e1 = self._sorted_iter(cur1, stack1, last_returned1)
        last_returned1.append(e1)
        var e2 = other._sorted_iter(cur2, stack2, last_returned2)
        last_returned2.append(e2)
        var compute1 = False
        var compute2 = False
        var cursor1 = 1
        var cursor2 = 1
        var increase1 = False
        var increase2 = False
        var num_eq = 0
        while True:
            if compute1 and cursor1 < num1:
                e1 = self._sorted_iter(cur1, stack1, last_returned1)
                last_returned1.clear()
                last_returned1.append(e1)
                increase1 = True
            if compute2 and cursor2 < num2:
                e2 = other._sorted_iter(cur2, stack2, last_returned2)
                last_returned2.clear()
                last_returned2.append(e2)
                increase2 = True
            let diff = cmp(e1, e2)
            if diff == 0:
                @parameter
                if type == Self.IsDisjoint:
                    return False
                compute1 = cursor1 < num1
                compute2 = cursor2 < num2
                num_eq += 1
            else:
                if diff < 0:
                    @parameter
                    if type == Self.IsSubset:
                        break
                    compute1 = True
                    compute2 = cursor1 >= num1
                else:
                    @parameter
                    if type == Self.IsSuperset:
                        break
                    compute1 = cursor2 >= num2
                    compute2 = True

            if increase1 and cursor1 < num1:
                cursor1 += 1
                increase1 = False
            if increase2 and cursor2 < num2:
                cursor2 += 1
                increase2 = False
            
            if cursor1 >= num1 and cursor2 >= num2:
                break

        @parameter
        if type == Self.IsSuperset:
            return num_eq == num2        
        @parameter
        if type == Self.IsSubset:
            return num_eq == num1
        @parameter
        if type == Self.IsDisjoint:
            return True
        return False
    
    @always_inline("nodebug")
    fn _sorted_iter(self, inout current: UInt32, inout stack: DynamicVector[UInt32], inout last_returned: DynamicVector[T]) -> T:
        # using UnsafeFixedVector[T](1) as poor mans Optional for last_returned
        if len(last_returned) == 0 or cmp(last_returned[0], self.elements[self.left[current.to_int()].to_int()]) < 0:
            while self.has_left(current):
                stack.push_back(current)
                current = self.left[current.to_int()]
        let result = self.elements[current.to_int()]
        if self.has_right(current):
                current = self.right[current.to_int()]
        else:
            current = stack.pop_back()
        return result
    
    @always_inline("nodebug")
    fn __len__(self) -> Int:
        return len(self.elements) - self.deleted
    
    @always_inline("nodebug")
    fn __contains__(self, element: T) -> Bool:
        return self._get_index(element).get[1, Int]() > -1
                    
    fn _get_index(self, element: T) -> (Int, Int):
        if self.__len__() == 0:
            return -1, -1
        if self.balanced:
            return self._get_index_balanced(element)
        var parent = 0
        var index = 0
        while True:
            let diff = cmp(self.elements[index], element)
            if diff == 0:
                return parent, index
            if diff > 0:
                let left = self.left[index].to_int()
                if left == index:
                    return index, -1
                else:
                    parent = index
                    index = left
            else:
                let right = self.right[index].to_int()
                if right == index:
                    return index, -1
                else:
                    parent = index
                    index = right
    
    fn _get_index_balanced(self, element: T) -> (Int, Int):
        var parent = 0
        var index = 0
        let len = self.__len__()
        while index < len:
            let diff = cmp(element, self.elements[index])
            if diff == 0:
                return parent, index
            parent = index
            index = (index + 1) * 2 + (diff >> 63)
        return parent, -1
    
    fn min_index(self) -> Int:
        if self.__len__() < 2:
            return self.__len__() - 1
        if self.balanced:
            return (1 << (self.max_depth.to_int() - 1)) - 1
        var cand = self.left[0]
        while self.has_left(cand):
            cand = self.left[cand.to_int()]
        return cand.to_int()
    
    fn max_index(self) -> Int:
        let size = self.__len__()
        if size < 2:
            return size - 1
        if self.balanced:
            if size == (1 << self.max_depth.to_int()) - 1:
                return size - 1
            return (1 << (self.max_depth.to_int() - 1)) - 2
        var cand = self.right[0]
        while self.has_right(cand):
            cand = self.right[cand.to_int()]
        return cand.to_int()
        
    
    fn _swap_with_next_smaller_leaf(inout self, index: UInt32) -> Bool:
        var parent = index
        var candidate = self.left[index.to_int()]
        if candidate == index:
            return False
        while True:
            if self._is_leaf(candidate):
                self.elements[index.to_int()] = self.elements[candidate.to_int()]
                self._delete_leaf(candidate.to_int(), parent.to_int())
                return True
            let right = self.right[candidate.to_int()]
            if right == candidate:
                self.elements[index.to_int()] = self.elements[candidate.to_int()]
                self.right[parent.to_int()] = self.left[candidate.to_int()]
                self.deleted += 1
                return True
            else:
                parent = candidate
                candidate = right
    
    @always_inline("nodebug")
    fn _is_leaf(self, index: UInt32) -> Bool:
        return (self.left[index.to_int()] == index).__bool__() and (self.right[index.to_int()] == index).__bool__()
    
    @always_inline("nodebug")
    fn _delete_leaf(inout self, index: Int, parent: Int):
        self.deleted += 1
        if self.left[parent] == index:
            self.left[parent] = parent
        else:
            self.right[parent] = parent  
    
    fn balance(inout self):
        if self.balanced:
            return
        let sorted_elements = self.sorted_elements()
        self._balance_with(sorted_elements)
    
    @always_inline("nodebug")
    fn _balance_with(inout self, sorted_elements: DynamicVector[T]):
        let new_size = len(sorted_elements)
        self.elements.resize(new_size, self.elements[len(self.elements) - 1])
        self.left.resize(new_size, 0)
        self.right.resize(new_size, 0)

        var i: Int = 0
        self._eytzinger(i, 1, sorted_elements)
        for index in range(new_size):
            let l = (index + 1) * 2 - 1
            let r = (index + 1) * 2
            if l < self.__len__():
                self.left[index] = l
            else:
                self.left[index] = index    
            if r < self.__len__():
                self.right[index] = r
            else:
                self.right[index] = index
        
        self.deleted = 0
        
        self.balanced = True
        self.max_depth = self._optimal_depth()
    
    fn _eytzinger(inout self, inout i: Int, k: Int, v: DynamicVector[T]):
        if k <= len(v):
            self._eytzinger(i, k * 2, v)
            self.elements[k - 1] = v[i]
            i += 1
            self._eytzinger(i, k * 2 + 1, v)
    
    fn print_tree(self, root: UInt32 = 0):
        if self.__len__() == 0:
            print("・")
            return
        self._print("", 0)
    
    fn _print(self, indentation: String, index: UInt32):
        if len(indentation) > 0:
            print(indentation, "-", to_str(self.elements[index.to_int()]))
        else:
            print("-", to_str(self.elements[index.to_int()]))

        if self.has_left(index):
            self._print(indentation + " ", self.left[index.to_int()])
        elif self.has_right(index):
            print(indentation + " ", "- ・")
        if self.has_right(index):
            self._print(indentation + " ", self.right[index.to_int()])
