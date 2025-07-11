class ProductModel {
  final String id;
  final String sku;
  final String namaProduk;
  final String kodeProduk;
  final String kategori;
  final String? subKategori;
  final String? barcode;
  final String? deskripsi;
  final String? supplier;
  final String unit;
  final double hargaSatuan;
  final int partai;
  final int keliling;
  final int ecer;
  final DateTime tanggalDibuat;
  final String? keterangan;
  final String status;
  final String? imageUrl;
  final String? createdBy;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.sku,
    required this.namaProduk,
    required this.kodeProduk,
    required this.kategori,
    this.subKategori,
    this.barcode,
    this.deskripsi,
    this.supplier,
    required this.unit,
    required this.hargaSatuan,
    required this.partai,
    required this.keliling,
    required this.ecer,
    required this.tanggalDibuat,
    this.keterangan,
    required this.status,
    this.imageUrl,
    this.createdBy,
    this.updatedAt,
  });

  // Calculate total stock
  int get totalStock => partai + keliling + ecer;

  // Get formatted price
  String get formattedPrice =>
      'Rp ${hargaSatuan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  // Get stock status
  String get stockStatus {
    if (totalStock == 0) return 'Habis';
    if (totalStock <= 10) return 'Stok Menipis';
    return 'Tersedia';
  }

  // Get stock status color
  String get stockStatusColor {
    if (totalStock == 0) return 'error';
    if (totalStock <= 10) return 'warning';
    return 'success';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'nama_produk': namaProduk,
      'kode_produk': kodeProduk,
      'kategori': kategori,
      'sub_kategori': subKategori,
      'barcode': barcode,
      'deskripsi': deskripsi,
      'supplier': supplier,
      'unit': unit,
      'harga_satuan': hargaSatuan,
      'partai': partai,
      'keliling': keliling,
      'ecer': ecer,
      'tanggal_dibuat': tanggalDibuat.toIso8601String(),
      'keterangan': keterangan,
      'status': status,
      'image_url': imageUrl,
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      namaProduk: json['nama_produk'] as String,
      kodeProduk: json['kode_produk'] as String,
      kategori: json['kategori'] as String,
      subKategori: json['sub_kategori'] as String?,
      barcode: json['barcode'] as String?,
      deskripsi: json['deskripsi'] as String?,
      supplier: json['supplier'] as String?,
      unit: json['unit'] as String,
      hargaSatuan: (json['harga_satuan'] as num).toDouble(),
      partai: json['partai'] as int,
      keliling: json['keliling'] as int,
      ecer: json['ecer'] as int,
      tanggalDibuat: DateTime.parse(json['tanggal_dibuat'] as String),
      keterangan: json['keterangan'] as String?,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      createdBy: json['created_by'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Copy with method
  ProductModel copyWith({
    String? id,
    String? sku,
    String? namaProduk,
    String? kodeProduk,
    String? kategori,
    String? subKategori,
    String? barcode,
    String? deskripsi,
    String? supplier,
    String? unit,
    double? hargaSatuan,
    int? partai,
    int? keliling,
    int? ecer,
    DateTime? tanggalDibuat,
    String? keterangan,
    String? status,
    String? imageUrl,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      namaProduk: namaProduk ?? this.namaProduk,
      kodeProduk: kodeProduk ?? this.kodeProduk,
      kategori: kategori ?? this.kategori,
      subKategori: subKategori ?? this.subKategori,
      barcode: barcode ?? this.barcode,
      deskripsi: deskripsi ?? this.deskripsi,
      supplier: supplier ?? this.supplier,
      unit: unit ?? this.unit,
      hargaSatuan: hargaSatuan ?? this.hargaSatuan,
      partai: partai ?? this.partai,
      keliling: keliling ?? this.keliling,
      ecer: ecer ?? this.ecer,
      tanggalDibuat: tanggalDibuat ?? this.tanggalDibuat,
      keterangan: keterangan ?? this.keterangan,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, sku: $sku, namaProduk: $namaProduk, totalStock: $totalStock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
