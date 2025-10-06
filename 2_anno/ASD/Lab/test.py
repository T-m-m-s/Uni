def Search(x, k, successor):  # x = root of RB-tree, k = key not present in the tree, successor initialized to None
    if x is None:
        return successor  # Base case: return the successor
    
    if k < x.key:
        # Update successor and move to the left subtree
        successor = x
        return Search(x.left, k, successor)
    elif k > x.key:
        # Move to the right subtree
        return Search(x.right, k, successor)
    else:
        # Key matches (should not happen as k is not in the tree)
        return successor