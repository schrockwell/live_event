# Used by "mix format"
[
  line_length: 120,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:phoenix_live_view],
  locals_without_parens: [
    assert_receive_event: 1,
    assert_receive_event: 2,
    assert_receive_event: 3,
    assert_received_event: 1,
    assert_received_event: 2,
    refute_receive_event: 1,
    refute_receive_event: 2,
    refute_receive_event: 3,
    refute_received_event: 1,
    refute_received_event: 2
  ],
  export: [
    locals_without_parens: [
      assert_receive_event: 1,
      assert_receive_event: 2,
      assert_receive_event: 3,
      assert_received_event: 1,
      assert_received_event: 2,
      refute_receive_event: 1,
      refute_receive_event: 2,
      refute_receive_event: 3,
      refute_received_event: 1,
      refute_received_event: 2
    ]
  ]
]
