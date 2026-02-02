import 'package:flutter/material.dart';

// App Colors - Updated based on reference image
const kPrimaryColor = Color(0xFF6F9AFA); // Soft blue
const kPrimaryLightColor = Color(0xFFF0F4FD); // Very light blue for backgrounds
const kAccentColor = Color(0xFFE69138); // Warm orange
const kBackgroundColor = Color(0xFFF5F7FA); // Off-white/gray background
const kCardColor = Colors.white;
const kTextColor = Color(0xFF2D3142); // Dark slate for text
const kTextSecondaryColor = Color(0xFF9196A2); // Gray for secondary text
const kDividerColor = Color(0xFFEDF1F7);

// Spacing
const double defaultPadding = 20.0;
const double defaultBorderRadius = 24.0;
const double cardElevation = 0.0; // Use shadows instead of elevation

// Text Styles
const kTitleStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: kTextColor,
  fontFamily: 'Outfit', // A modern font often used in such designs
);

const kSubtitleStyle = TextStyle(
  fontSize: 16,
  color: kTextSecondaryColor,
  fontFamily: 'Outfit',
);

const kCardTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextColor,
);

const kButtonTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w600,
  fontSize: 16,
);
