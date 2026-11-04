import 'package:flutter/material.dart';

/// Centralized repository for all mock test assets and image references.
/// Isolates all image paths to this single file per system design requirement.
class MockTestAssets {
  // Prevent instantiation
  MockTestAssets._();

  // Avatar Assets
  static const String avatarAdmin = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150';
  static const String avatarCustomer = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';
  static const String avatarLabOwner = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150';
  static const String avatarExpert = 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150';
  static const String avatarUser1 = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150';
  static const String avatarUser2 = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150';
  static const String avatarUser3 = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150';

  // Lab Covers & Logos
  static const String labCoverCroplab = 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800';
  static const String labLogoCroplab = 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=200';
  static const String labCoverLlab = 'https://images.unsplash.com/photo-1452784444945-3f422708fe5e?w=800';
  static const String labLogoLlab = 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=200';
  static const String labCoverNadir = 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800';
  static const String labLogoNadir = 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=200';
  static const String labCoverRetroHanoi = 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800';
  static const String labCoverSongHan = 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=800';

  // Convenient Aliases for Lab Covers
  static const String labCover1 = labCoverLlab;
  static const String labCover2 = labCoverCroplab;
  static const String labCover3 = labCoverNadir;

  // Laboratory Machine Verification Photos (KYC & Darkroom)
  static const String machineNoritsu = 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800';
  static const String machineFrontier = 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800';
  static const String machineDarkroomSink = 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800';
  static const String certificateWaste = 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=800';

  // Photo Archive Scans
  static const String photoHanoiAfternoon = 'https://images.unsplash.com/photo-1528127269322-539801943592?w=1200';
  static const String photoStreetVendor = 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1200';
  static const String photoSaigonCafe = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1200';
  static const String photoDalatPine = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200';
  static const String photoHoiAnNight = 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200';
  static const String photoFilmStripExpose = 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=1200';

  // Convenient Aliases for Sample Photos
  static const String samplePhoto1 = photoHanoiAfternoon;
  static const String samplePhoto2 = photoStreetVendor;
  static const String samplePhoto3 = photoSaigonCafe;
  static const String samplePhoto4 = photoDalatPine;
  static const String samplePhoto5 = photoHoiAnNight;

  // Marketplace Equipment Listings
  static const String equipCanonQL17 = 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800';
  static const String equipLeicaM6 = 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800';
  static const String equipOlympusOM1 = 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800';
  static const String equipKodakPortra400 = 'https://images.unsplash.com/photo-1452784444945-3f422708fe5e?w=800';
  static const String equipFujiC200 = 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800';

  // Convenient Aliases for Marketplace
  static const String marketplaceCam1 = equipCanonQL17;
  static const String marketplaceCam2 = equipLeicaM6;
  static const String marketplaceCam3 = equipOlympusOM1;

  // Community Events & Photowalks
  static const String eventPhotowalkChoLon = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800';
  static const String eventWorkshopBW = 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800';

  /// Safe Image Provider supporting both positional and named url with graceful offline fallback
  static Widget image(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    Widget img = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF2EFE9),
        child: const Center(
          child: Icon(Icons.photo_camera_back, size: 24, color: Color(0xFF5F5A52)),
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: img);
    }
    return img;
  }
}
