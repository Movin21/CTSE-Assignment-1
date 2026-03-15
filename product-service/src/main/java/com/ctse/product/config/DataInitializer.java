package com.ctse.product.config;

import com.ctse.product.entity.Product;
import com.ctse.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final ProductRepository productRepository;

    @Override
    public void run(String... args) {
        if (productRepository.count() > 0) {
            return;
        }

        List<Product> products = List.of(
            Product.builder()
                .name("Ultra HDTV 55\" 4K")
                .description("Stunning 4K OLED display with HDR10+, 120Hz refresh rate, and built-in smart OS.")
                .price(new BigDecimal("1299.99"))
                .stockQuantity(25)
                .category("Electronics")
                .imageUrl("https://images.unsplash.com/photo-1593359677879-a4bb92f4834a?w=400")
                .build(),
            Product.builder()
                .name("Mechanical Gaming Keyboard")
                .description("TKL layout, Cherry MX Blue switches, per-key RGB, USB-C detachable cable.")
                .price(new BigDecimal("149.99"))
                .stockQuantity(80)
                .category("Peripherals")
                .imageUrl("https://images.unsplash.com/photo-1541140532154-b024d705b90a?w=400")
                .build(),
            Product.builder()
                .name("Wireless Noise-Cancelling Headphones")
                .description("40-hour battery life, ANC, Hi-Res Audio certified, foldable design.")
                .price(new BigDecimal("349.99"))
                .stockQuantity(50)
                .category("Audio")
                .imageUrl("https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400")
                .build(),
            Product.builder()
                .name("Ergonomic Office Chair")
                .description("Lumbar support, breathable mesh, adjustable armrests, 5-year warranty.")
                .price(new BigDecimal("499.99"))
                .stockQuantity(15)
                .category("Furniture")
                .imageUrl("https://images.unsplash.com/photo-1592078615290-033ee584e267?w=400")
                .build()
        );

        productRepository.saveAll(products);
        System.out.println("[Product Service] Seeded " + products.size() + " sample products.");
    }
}
