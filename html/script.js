let selectedItems = [];
let totalAmount = 0;

document.addEventListener('DOMContentLoaded', function() {
    // Listen for NUI messages
    window.addEventListener('message', function(event) {
        const data = event.data;

        if (data.action === 'open') {
            document.body.style.display = 'block';
            resetInterface();
        }
    });

    // Category selection
    const categories = document.querySelectorAll('.category');
    categories.forEach(category => {
        category.addEventListener('click', function() {
            // Remove active class from all categories
            categories.forEach(cat => cat.classList.remove('active'));

            // Add active class to clicked category
            this.classList.add('active');

            // Hide all category items
            document.querySelectorAll('.category-items').forEach(items => {
                items.style.display = 'none';
            });

            // Show selected category items
            const categoryName = this.getAttribute('data-category');
            document.getElementById(`${categoryName}-items`).style.display = 'block';
        });
    });

    // Set weapons as default active category
    document.querySelector('[data-category="weapons"]').classList.add('active');

    // Item selection
    document.querySelectorAll('.item-select').forEach(selectBtn => {
        selectBtn.addEventListener('click', function() {
            const item = this.parentElement;
            const itemName = item.querySelector('.item-name').textContent;
            const itemPrice = parseInt(item.getAttribute('data-price'));
            const itemId = item.getAttribute('data-item');

            // Check if item is already selected
            const existingItem = selectedItems.find(i => i.id === itemId);

            if (existingItem) {
                // Increase quantity
                existingItem.quantity += 1;
                updateSelectedItemsDisplay();
            } else {
                // Add new item
                selectedItems.push({
                    id: itemId,
                    name: itemName,
                    price: itemPrice,
                    quantity: 1
                });
                updateSelectedItemsDisplay();
            }

            // Update total
            calculateTotal();
        });
    });

    // Place order button
    document.getElementById('place-order').addEventListener('click', function() {
        closeMenu();
        if (selectedItems.length === 0) {
            // No items selected
            return;
        }

        // Send order to client script
        fetch('https://qr-blackmarket/placeOrder', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                items: selectedItems,
                total: totalAmount
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                closeMenu();
            }
        })
        .catch(error => {
            console.error('Error placing order:', error);
        });
    });

    // Cancel order button
    document.getElementById('cancel-order').addEventListener('click', function() {
        closeMenu();
    });

    // Close on ESC key
    document.addEventListener('keyup', function(event) {
        if (event.key === 'Escape') {
            closeMenu();
        }
    });
});

// Update the selected items display
function updateSelectedItemsDisplay() {
    const selectedItemsContainer = document.getElementById('selected-items');

    if (selectedItems.length === 0) {
        selectedItemsContainer.innerHTML = '<p class="no-items">No items selected</p>';
        return;
    }

    selectedItemsContainer.innerHTML = '';

    selectedItems.forEach((item, index) => {
        const itemElement = document.createElement('div');
        itemElement.className = 'selected-item';

        itemElement.innerHTML = `
            <div>${item.name} x${item.quantity}</div>
            <div>$${(item.price * item.quantity).toLocaleString()}</div>
            <div class="selected-item-remove" data-index="${index}">X</div>
        `;

        selectedItemsContainer.appendChild(itemElement);
    });

    // Add event listeners to remove buttons
    document.querySelectorAll('.selected-item-remove').forEach(removeBtn => {
        removeBtn.addEventListener('click', function() {
            const index = parseInt(this.getAttribute('data-index'));

            if (selectedItems[index].quantity > 1) {
                // Decrease quantity
                selectedItems[index].quantity -= 1;
            } else {
                // Remove item
                selectedItems.splice(index, 1);
            }

            updateSelectedItemsDisplay();
            calculateTotal();
        });
    });
}

// Calculate total amount
function calculateTotal() {
    totalAmount = selectedItems.reduce((total, item) => {
        return total + (item.price * item.quantity);
    }, 0);

    document.querySelector('.total-amount').textContent = `$${totalAmount.toLocaleString()}`;
}

// Reset interface
function resetInterface() {
    selectedItems = [];
    totalAmount = 0;

    // Reset selected items display
    document.getElementById('selected-items').innerHTML = '<p class="no-items">No items selected</p>';

    // Reset total
    document.querySelector('.total-amount').textContent = '$0';

    // Set weapons as active category
    document.querySelectorAll('.category').forEach(cat => cat.classList.remove('active'));
    document.querySelector('[data-category="weapons"]').classList.add('active');

    // Show weapons items
    document.querySelectorAll('.category-items').forEach(items => {
        items.style.display = 'none';
    });
    document.getElementById('weapons-items').style.display = 'block';
}

// Close menu
function closeMenu() {
    document.body.style.display = 'none';
    fetch('https://qr-blackmarket/closeMenu', {
        method: 'POST'
    });
}
